class Upsell < ApplicationRecord

    belongs_to :property
    validates :title, presence: true
    validates :price, presence: true
    validates :description, presence: true

end
