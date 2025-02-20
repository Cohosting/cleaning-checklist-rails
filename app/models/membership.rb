class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :role, presence: true
end
