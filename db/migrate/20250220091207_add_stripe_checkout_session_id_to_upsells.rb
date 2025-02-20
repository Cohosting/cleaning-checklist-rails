class AddStripeCheckoutSessionIdToUpsells < ActiveRecord::Migration[8.0]
  def change
    add_column :upsells, :stripe_checkout_session_id, :string
  end
end
