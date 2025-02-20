class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access
  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      render json: { error: "Invalid payload" }, status: 400 and return
    rescue Stripe::SignatureVerificationError
      render json: { error: "Invalid signature" }, status: 400 and return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      puts session.inpect
      upsell = Upsell.find_by(stripe_checkout_session_id: session.id)
      puts "Found Upsell: #{upsell.inspect}"
      upsell.update!(status: 'paid') if upsell

    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    head :ok
  end
end
