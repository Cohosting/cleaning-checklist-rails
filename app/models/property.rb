class Property < ApplicationRecord
    # A property has one default checklist
    belongs_to :default_checklist, class_name: "Checklist", optional: true
  
    # A property can have many checklists
    has_many :checklists, dependent: :destroy
    has_many :upsells , dependent: :destroy
  
    # A property can have many jobs
    has_many :jobs, dependent: :destroy
    has_many :reservations, dependent: :destroy
  
    # Validations
    validates :name, presence: true
    validates :address, presence: true



  end