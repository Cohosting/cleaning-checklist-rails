class Group < ApplicationRecord
  belongs_to :organization
  has_many :section_groups, dependent: :destroy
  has_many :sections, through: :section_groups
  
  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
