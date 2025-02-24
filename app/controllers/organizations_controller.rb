class OrganizationsController < ApplicationController
  before_action :require_authentication

  def show
    @organization = Organization.find(params[:id])
    authorize_access!

    @members = @organization.memberships.includes(:user).map do |membership|
      { email: membership.user.email_address, role: membership.role }
    end

    @pending_invites = @organization.invitations.map do |invitation|
      { email: invitation.email, role: invitation.role }
    end
  end

  private

  def authorize_access!
    unless Current.user.memberships.exists?(organization: @organization) || Current.user.organization == @organization
      redirect_to root_path, alert: "You don’t have access to this organization."
    end
  end
end