class SyncReservationsJob < ApplicationJob
  queue_as :default

  def perform(property_hospitable_id)
    Rails.logger.info "Syncing reservations for property #{property_hospitable_id}"

    property = Property.find_by(hospitable_id: property_hospitable_id)

    if property.nil?
      Rails.logger.warn "Property with hospitable_id #{property_hospitable_id} not found. Skipping sync."
      return
    end

    reservations = fetch_reservations(property_hospitable_id) || []
    Rails.logger.info "Fetched #{reservations.count} reservations"

    reservations.each do |reservation_data|
      Rails.logger.info "Processing reservation: #{reservation_data.inspect}"

      guest_data = reservation_data['guest']
      if guest_data.nil?
        Rails.logger.warn "Missing guest data for reservation: #{reservation_data.inspect}"
        next
      end

      guest = Guest.find_or_create_by(hospitable_id: guest_data['id']) do |g|
        g.first_name = guest_data['first_name']
        g.last_name = guest_data['last_name']
        g.email = guest_data['email']
        g.phone_numbers = guest_data['phone_numbers']
      end

      # Safely extract financials
      total_price = reservation_data.dig('financials', 'guest', 'total_price', 'amount') || 0
      total_price /= 100.0  # Convert cents to dollars if necessary
      currency = reservation_data.dig('financials', 'currency') || 'USD'

      reservation = Reservation.find_or_initialize_by(
        platform: reservation_data['platform'],
        platform_id: reservation_data['platform_id'],
        hospitable_reservation_id: reservation_data['id']
      )

      reservation.assign_attributes(
        guest: guest,
        property: property, 
        booking_date: reservation_data['booking_date'],
        arrival_date: reservation_data['arrival_date'],
        departure_date: reservation_data['departure_date'],
        nights: reservation_data['nights'],
        check_in: reservation_data['check_in'],
        check_out: reservation_data['check_out'],
        status: reservation_data['status'],
        total_price: total_price,
        currency: currency
      )
      reservation.save!
    end
    Rails.logger.info "Processed #{reservations.count} reservations"
  rescue StandardError => e
    Rails.logger.error "SyncReservationsJob failed: #{e.message}\n#{e.backtrace.join("\n")}"
    raise
  end

  private

  def fetch_reservations(property_hospitable_id)
    response = HTTParty.get(
      "https://public.api.hospitable.com/v2/reservations",
      query: { 
        "properties[]" => property_hospitable_id,
        "include" => "financials,guest" 
      },
      headers: { "Authorization" => "Bearer #{Rails.application.credentials.hospitable_api_key}" }
    )
  
    unless response.success?
      Rails.logger.error "API request failed: #{response.code} - #{response.body}"
      return []
    end
  
    parsed_body = JSON.parse(response.body)
    data = parsed_body['data']
  
    if data.nil?
      Rails.logger.warn "No 'data' key in API response: #{parsed_body.inspect}"
      return []
    end
  
    data
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse API response: #{e.message} - Response body: #{response.body}"
    []
  end
end
