class Property < ApplicationRecord
    has_many :checklists, dependent: :destroy
    
    validates :name, presence: true
    validates :address, presence: true
end
