class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @accept_url = accept_invitations_url(token: invitation.token)
   puts "InvitationMailer: invite: @accept_url: #{@accept_url}"
    mail(to: invitation.email, subject: "You've been invited to join an organization")
  end
end