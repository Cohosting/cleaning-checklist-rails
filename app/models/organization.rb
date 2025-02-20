class Organization < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :invitations, dependent: :destroy

  def invite_user(email, role)
    invitation = invitations.create!(email: email)
    InvitationMailer.invite(invitation).deliver_later
  end

  def accept_invitation(token, password)
    invitation = invitations.find_by(token: token)
    return unless invitation

    user = User.create!(email_address: invitation.email, password: password)
    memberships.create!(user: user, role: "cleaner") # Default role

    invitation.destroy
    user
  end
end
