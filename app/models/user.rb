
class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  has_many :sessions, dependent: :destroy

  
  validates :email_address, presence: true, uniqueness: true

  after_commit :ensure_default_organization, on: :create

  private

  def ensure_default_organization
    org = Organization.create!(name: "#{email_address}'s Organization", owner: self)
    memberships.create!(organization: org, role: "owner")
  end
end
