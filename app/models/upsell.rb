class Upsell < ApplicationRecord
    belongs_to :organization
    has_many :upsell_properties
    has_many :properties, through: :upsell_properties
    
    # Add positional ordering
    acts_as_list scope: :organization
    
    # Default scope to order by position
    default_scope { order(position: :asc) }
    
    # Existing validations
    validates :title, presence: true
    validates :price, presence: true
    validates :description, presence: true
  end