class UsersController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]

  def new
    @invitation_token = params[:invitation_token] # Store for form
    @user = User.new
    if @invitation_token
      invitation = Invitation.find_by(token: @invitation_token)
      if invitation
        @user.email_address = invitation.email
      else
        redirect_to root_path, alert: "Invalid invitation token."
        return
      end
    end
  end

  def create
    @invitation_token = params[:invitation_token] || params.dig(:user, :invitation_token)
    @user = User.new(user_params)
    invited = @invitation_token.present?
    Rails.logger.debug "Before save: invited = #{invited}, token = #{@invitation_token}"

    if @user.save
      if invited
        invitation = Invitation.find_by(token: @invitation_token)
        if invitation
          Rails.logger.debug "Adding user to inviting org: #{invitation.organization.name}"
          invitation.organization.memberships.create!(user: @user, role: invitation.role)
          invitation.destroy
          Rails.logger.debug "Added #{@user.email_address} to #{invitation.organization.name}"
          start_new_session_for(@user)
          redirect_to organization_path(invitation.organization), notice: "You have successfully joined the organization."
        else
          Rails.logger.debug "Invalid invitation token during acceptance: #{@invitation_token}"
          start_new_session_for(@user)
          redirect_to after_authentication_url, alert: "Invitation token invalid or expired."
        end
      else
        Rails.logger.debug "Creating default organization for #{@user.email_address}"
        new_org = Organization.create!(name: "#{@user.email_address}'s Organization", owner: @user)
        @user.update!(organization: new_org)
        @user.memberships.create!(organization: new_org, role: "admin")
        start_new_session_for(@user)
        redirect_to organization_path(new_org), notice: "Account created successfully."
      end
    else
      Rails.logger.debug "User save failed: #{@user.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end