class PropertyGroup < ApplicationRecord
  belongs_to :property
  belongs_to :group

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :group_id, uniqueness: { scope: :property_id }
end
