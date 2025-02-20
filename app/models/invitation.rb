class Invitation < ApplicationRecord
  belongs_to :organization
  before_create :generate_token

  validates :email, presence: true, uniqueness: { scope: :organization_id }

  private

  def generate_token
    self.token = SecureRandom.hex(10)
  end
end
