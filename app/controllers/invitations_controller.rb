class InvitationsController < ApplicationController
  include Authentication

  before_action :require_authentication, only: [:create, :create_subcontractor]
  allow_unauthenticated_access only: :accept

  def create
    organization = Organization.find(params[:organization_id])
    unless Current.user.can_invite_to?(organization)
      redirect_to organization_path(organization), alert: "You are not authorized to invite members to this organization."
      return
    end

    email = params[:email]
    role = params[:role] || "member"

    if email.blank?
      redirect_to organization_path(organization), alert: "Email cannot be blank."
      return
    end

    if organization.users.exists?(email_address: email)
      redirect_to organization_path(organization), alert: "This user (#{email}) is already a member of the organization."
      return
    end

    if organization.invitations.exists?(email: email)
      redirect_to organization_path(organization), alert: "An invitation has already been sent to #{email}."
      return
    end

    invitation = organization.invitations.build(email: email, role: role)
    if invitation.save
      InvitationMailer.invite(invitation).deliver_now
      redirect_to organization_path(organization), notice: "Invitation successfully sent to #{email}."
    else
      redirect_to organization_path(organization), alert: "Failed to send invitation: #{invitation.errors.full_messages.join(', ')}."
    end
  end

  # New method for contractors to invite subcontractors
  def create_subcontractor
    organization = Organization.find(params[:organization_id])
    
    # Verify that current user is a contractor in this organization
    unless Current.user.contractor_in?(organization)
      redirect_to organization_path(organization), alert: "Only contractors can invite subcontractors."
      return
    end
    
    email = params[:email]
    
    if email.blank?
      redirect_to organization_path(organization), alert: "Email cannot be blank."
      return
    end
    
    if organization.users.exists?(email_address: email)
      redirect_to organization_path(organization), alert: "This user (#{email}) is already a member of the organization."
      return
    end
    
    if organization.invitations.exists?(email: email)
      redirect_to organization_path(organization), alert: "An invitation has already been sent to #{email}."
      return
    end
    
    # Create an invitation with role 'subcontractor' and store the contractor's ID
    invitation = organization.invitations.build(
      email: email, 
      role: 'subcontractor',
      invited_by_user_id: Current.user.id,
      token: SecureRandom.hex(20)  # Ensure token is generated
    )
    
    if invitation.save
      InvitationMailer.invite_subcontractor(invitation).deliver_now
      redirect_to organization_path(organization), notice: "Subcontractor invitation sent to #{email}."
    else
      redirect_to organization_path(organization), alert: "Failed to send invitation: #{invitation.errors.full_messages.join(', ')}."
    end
  end

  def accept
    @invitation = Invitation.find_by(token: params[:token])
    unless @invitation
      redirect_to root_path, alert: "Invalid or expired invitation token."
      return
    end

    if authenticated?
      if Current.user.email_address == @invitation.email
        process_acceptance
      else
        flash.now[:alert] = "This invitation is for #{@invitation.email}, not your account (#{Current.user.email_address}). Please log out and use the correct account."
        render :accept, status: :unprocessable_entity 
      end
    else
      render :accept, status: :unprocessable_entity
    end
  end

  private

  def process_acceptance
    organization = @invitation.organization
    
    # If user is already a direct member of the organization, just remove the invitation
    if organization.memberships.exists?(user: Current.user)
      @invitation.destroy
      redirect_to organization_path(organization), notice: "You are already a member of this organization."
      return
    end
    
    # Begin transaction to ensure data consistency
    ActiveRecord::Base.transaction do
      case @invitation.role
      when 'subcontractor'
        # This is a subcontractor invitation
        # We don't create a membership, but establish a contractor-subcontractor relationship
        contractor = User.find(@invitation.invited_by_user_id)
        
        # Create the contractor-subcontractor relationship if it doesn't exist
        unless ContractorSubcontractor.exists?(contractor: contractor, subcontractor: Current.user)
          ContractorSubcontractor.create!(contractor: contractor, subcontractor: Current.user)
        end
        
        # No membership is created for the subcontractor
        # No organization_id is set for subcontractors since they access via their contractor
      when 'contractor'
        # Ensure the user has a contractor profile
        Current.user.create_contractor_profile unless Current.user.contractor_profile.present?
        
        # Create membership for the contractor
        organization.memberships.create!(user: Current.user, role: 'contractor')
        
        # Update the user's organization_id if they don't have one yet
        # This maintains compatibility with your existing code that expects user.organization_id
        if Current.user.organization_id.nil?
          Current.user.update(organization_id: organization.id)
        end
      else
        # Standard membership (owner, admin, member, etc.)
        organization.memberships.create!(user: Current.user, role: @invitation.role)
        
        # Update the user's organization_id if they don't have one yet
        # This maintains compatibility with your existing code that expects user.organization_id
        if Current.user.organization_id.nil?
          Current.user.update(organization_id: organization.id)
        end
      end
      
      # Delete the invitation
      @invitation.destroy
    end
    
    # After processing, redirect the user to the appropriate place
    if @invitation.role == 'subcontractor'
      # Subcontractors should see the contractor's organization
      redirect_to organization_path(organization), notice: "You have successfully become a subcontractor for #{User.find(@invitation.invited_by_user_id).email_address}."
    else
      # Direct members and contractors see their organization dashboard
      redirect_to organization_path(organization), notice: "You have successfully joined the organization."
    end
  end
end