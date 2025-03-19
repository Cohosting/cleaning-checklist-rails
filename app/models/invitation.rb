class Invitation < ApplicationRecord
  belongs_to :organization

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  belongs_to :invited_by_user, class_name: 'User', optional: true

  before_validation :generate_token, on: :create
  def invited_by_contractor?
    invited_by_user_id.present? && invited_by_user.contractor?
  end
  private

  def generate_token
    self.token ||= SecureRandom.hex(20)
  end
end