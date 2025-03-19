
class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  belongs_to :organization, optional: true  
  has_many :sessions, dependent: :destroy

  
  validates :email_address, presence: true, uniqueness: true

# Contractor relationships
has_one :contractor_profile, dependent: :destroy

# Users who this user is a contractor for (their subcontractors)
has_many :contractor_relationships, class_name: 'ContractorSubcontractor', 
         foreign_key: 'contractor_id', dependent: :destroy
has_many :subcontractors, through: :contractor_relationships, source: :subcontractor

# Users who this user is a subcontractor for (their contractors)
has_many :subcontractor_relationships, class_name: 'ContractorSubcontractor', 
         foreign_key: 'subcontractor_id', dependent: :destroy
has_many :contractors, through: :subcontractor_relationships, source: :contractor

# Helper methods
def contractor?
  contractor_profile.present?
end

def contractor_in?(organization)
  memberships.where(organization: organization, role: 'contractor').exists?
end

# Get all organizations where user is a subcontractor through their contractors
def subcontractor_organizations
  # Find all contractors who have memberships in organizations
  contractors.joins(:memberships)
             .where(memberships: { role: 'contractor' })
             .select('memberships.organization_id')
             .map(&:organization_id)
             .uniq
             .map { |org_id| Organization.find(org_id) }
end

# Check if user is a subcontractor in an organization (through a contractor)
def subcontractor_in?(organization)
  # Check if any of user's contractors are members of this organization as contractors
  contractors.joins(:memberships)
             .where(memberships: { organization_id: organization.id, role: 'contractor' })
             .exists?
end

# Find the contractors who connect this subcontractor to an organization
def contractors_in_organization(organization)
  contractors.joins(:memberships)
             .where(memberships: { organization_id: organization.id, role: 'contractor' })
end

def role_in(organization)
  # Check if user is a direct member
  membership = memberships.find_by(organization: organization)
  return membership.role if membership
  
  # Check if user is a subcontractor
  if subcontractor_in?(organization)
    return "subcontractor"
  end
  
  # No role
  nil
end

# Check if user is a direct member of an organization
def member_of?(organization)
  memberships.exists?(organization: organization)
end

# Check if user can access an organization (either as member or subcontractor)
def can_access?(organization)
  member_of?(organization) || subcontractor_in?(organization)
end

    # Define permission check for inviting to an organization
    def can_invite_to?(organization)
      membership = memberships.find_by(organization: organization)
      return false unless membership # User must be a member
      membership.role == "admin" || organization.owner_id == id # Admins or owner can invite
    end

  private



end
