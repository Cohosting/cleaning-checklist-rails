# app/controllers/concerns/stripe_checkout.rb
require 'stripe'
module StripeCheckout
    extend ActiveSupport::Concern
  
    def create_checkout_session(item)
      Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: [build_line_item(item)],
        mode: 'payment',
        success_url: success_url(item),
        cancel_url: cancel_url(item)
      )
    end
  
    private
  
    def build_line_item(item)
      {
        price_data: {
          currency: 'usd',
          unit_amount: (item.price * 100).to_i,
          product_data: {
            name: item.title,
            description: item.description
          }
        },
        quantity: 1
      }
    end
  
    def success_url(item)
      upsell_url(item) + '?success=true'
    end
  
    def cancel_url(item)
      upsell_url(item)
    end
  end