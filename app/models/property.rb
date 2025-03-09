class Property < ApplicationRecord
    # A property has one default checklist
    belongs_to :default_checklist, class_name: "Checklist", optional: true
      belongs_to :organization

  
    # A property can have many checklists
    has_many :checklists, dependent: :destroy
    has_many :upsell_properties
    has_many :upsells, through: :upsell_properties  
    # A property can have many jobs
    has_many :jobs, dependent: :destroy
    has_many :reservations, dependent: :destroy

    has_many :property_groups, dependent: :destroy

  
    # Validations
    validates :name, presence: true
    validates :address, presence: true
    scope :search, ->(query) {
      if query.present?
        where("name LIKE :query OR name LIKE :query", query: "%#{query}%")
      end
    }
    

  end

  