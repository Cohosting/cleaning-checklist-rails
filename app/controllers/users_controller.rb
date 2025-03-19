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
          organization = invitation.organization
          
          if invitation.role == 'subcontractor' && invitation.invited_by_user_id.present?
            # This is a subcontractor invitation
            Rails.logger.debug "Processing subcontractor invitation from user #{invitation.invited_by_user_id}"
            
            # Create the contractor-subcontractor relationship
            contractor = User.find(invitation.invited_by_user_id)
            ContractorSubcontractor.create!(
              contractor: contractor,
              subcontractor: @user
            )
            
            # No membership is created, but set organization_id for UI purposes
            @user.update!(organization_id: organization.id)
            
            invitation.destroy
            start_new_session_for(@user)
            redirect_to organization_path(organization), 
                        notice: "You have been added as a subcontractor for #{contractor.email_address}."
          else
            # Standard invitation (member, admin, contractor)
            Rails.logger.debug "Adding user to inviting org: #{organization.name}"
            organization.memberships.create!(user: @user, role: invitation.role)
            
            # If this is a contractor, create their contractor profile
            if invitation.role == 'contractor'
              @user.create_contractor_profile unless @user.contractor_profile.present?
            end
            
            # Set organization_id for current context
            @user.update!(organization_id: organization.id)
            
            invitation.destroy
            Rails.logger.debug "Added #{@user.email_address} to #{organization.name}"
            start_new_session_for(@user)
            redirect_to organization_path(organization), 
                        notice: "You have successfully joined the organization."
          end
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