
class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  belongs_to :organization, optional: true # Directly uses organization_id
  has_many :sessions, dependent: :destroy

  
  validates :email_address, presence: true, uniqueness: true



    # Define permission check for inviting to an organization
    def can_invite_to?(organization)
      membership = memberships.find_by(organization: organization)
      return false unless membership # User must be a member
      membership.role == "admin" || organization.owner_id == id # Admins or owner can invite
    end
  private



end
