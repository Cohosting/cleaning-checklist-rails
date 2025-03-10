# config/initializers/stripe.rb
Rails.application.config.after_initialize do
  Rails.configuration.stripe = {
    publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key),
    secret_key: Rails.application.credentials.dig(:stripe, :secret_key)
  }

  Stripe.api_key = Rails.configuration.stripe[:secret_key]
end
