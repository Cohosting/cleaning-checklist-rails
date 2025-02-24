# class InvitationsController < ApplicationController
#     allow_unauthenticated_access only: :accept
#     before_action :require_authentication, only: :create
#     def create
#       organization = Organization.find(params[:organization_id])
#       unless Current.user.can_invite_to?(organization)
#         redirect_to organization_path(organization), alert: "You are not authorized to invite members to this organization."
#         return
#       end
  
#       email = params[:email]
#       role = params[:role] || "member"
  
#       if email.blank?
#         redirect_to organization_path(organization), alert: "Email cannot be blank."
#         return
#       end
  
#       if organization.users.exists?(email_address: email)
#         redirect_to organization_path(organization), alert: "This user (#{email}) is already a member of the organization."
#         return
#       end
  
#       if organization.invitations.exists?(email: email)
#         redirect_to organization_path(organization), alert: "An invitation has already been sent to #{email}."
#         return
#       end
  
#       invitation = organization.invitations.build(email: email, role: role)
#       if invitation.save
#         InvitationMailer.invite(invitation).deliver_now
#         redirect_to organization_path(organization), notice: "Invitation successfully sent to #{email}."
#       else
#         redirect_to organization_path(organization), alert: "Failed to send invitation: #{invitation.errors.full_messages.join(', ')}."
#       end
#     end
  

#     def accept
#       @invitation = Invitation.find_by(token: params[:token])
#       unless @invitation
#         redirect_to root_path, alert: "Invalid or expired invitation token."
#         return
#       end
  
#       if authenticated?
#         if Current.user.email_address == @invitation.email
#           process_acceptance
#         else
#           flash.now[:alert] = "This invitation is for #{@invitation.email}, not your account (#{Current.user.email_address}). Please log out and use the correct account."
#           render :accept
#         end
#       else
#         render :accept
#       end
#     end
  
#     private
  
#     def process_acceptance
#       organization = @invitation.organization
#       if organization.memberships.exists?(user: Current.user)
#         @invitation.destroy
#         redirect_to organization_path(organization), notice: "You are already a member of this organization."
#       else
#         organization.memberships.create!(user: Current.user, role: @invitation.role)
#         @invitation.destroy
#         redirect_to organization_path(organization), notice: "You have successfully joined the organization."
#       end
#     rescue ActiveRecord::RecordInvalid => e
#       redirect_to root_path, alert: "An error occurred: #{e.message}"
#     end
#   end
class InvitationsController < ApplicationController
  include Authentication

  before_action :require_authentication, only: :create
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
    if organization.memberships.exists?(user: Current.user)
      @invitation.destroy
      redirect_to organization_path(organization), notice: "You are already a member of this organization."
    else
      organization.memberships.create!(user: Current.user, role: @invitation.role)
      @invitation.destroy
      redirect_to organization_path(organization), notice: "You have successfully joined the organization."
    end
  end
end