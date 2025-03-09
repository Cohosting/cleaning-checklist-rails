class UpsellProperty < ApplicationRecord

    belongs_to :upsell
    belongs_to :property
end
