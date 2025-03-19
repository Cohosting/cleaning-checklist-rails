class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @accept_url = accept_invitations_url(token: invitation.token)
   puts "InvitationMailer: invite: @accept_url: #{@accept_url}"
    mail(to: invitation.email, subject: "You've been invited to join an organization")
  end
  def invite_subcontractor(invitation)
    @invitation = invitation
    @organization = invitation.organization
    @contractor = invitation.invited_by_user
    
    mail(
      to: invitation.email,
      subject: "You've been invited as a subcontractor for #{@contractor.email_address} in #{@organization.name}"
    )
  end
end