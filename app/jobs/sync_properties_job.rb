class SyncPropertiesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Syncing properties from Hospitable"

    properties = fetch_properties
    properties ||= []
    Rails.logger.info "Fetched #{properties.count} properties"

    properties.each do |property_data|
      Rails.logger.info "Processing property: #{property_data['id']}"

      property = Property.find_or_initialize_by(hospitable_id: property_data['id'])
      property.assign_attributes(
        name: property_data['name'],
        address: property_data.dig('address', 'display')
      )
      property.save!
    end

    Rails.logger.info "Processed #{properties.count} properties"
  rescue StandardError => e
    Rails.logger.error "SyncPropertiesJob failed: #{e.message}\n#{e.backtrace.join("\n")}"
    raise
  end

  private

  def fetch_properties
    response = HTTParty.get(
      "https://public.api.hospitable.com/v2/properties",
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
