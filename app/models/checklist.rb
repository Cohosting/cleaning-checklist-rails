class Checklist < ApplicationRecord
  belongs_to :organization
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :tasks, through: :sections
  
  validates :title, presence: true
end
