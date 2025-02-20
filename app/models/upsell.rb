class Upsell < ApplicationRecord
    validates :title, presence: true
    validates :price, presence: true
    validates :description, presence: true

end
