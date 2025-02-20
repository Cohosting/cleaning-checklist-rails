class InvitationsController < ApplicationController
    before_action :require_authentication, only: [:create]
    allow_unauthenticated_access only: [:accept, :process_accept]
  
    def create
      org = Current.user.organizations.first
      email = params[:email]
      
      if org.invite_user(email, "cleaner")
        redirect_to root_path, notice: "Invitation sent to #{email}"
      else
        redirect_to root_path, alert: "Failed to send invitation"
      end
    end
  
    def accept
      @invitation = Invitation.find_by(token: params[:token])
      redirect_to root_path, alert: "Invalid invitation" unless @invitation
    end
  
    def process_accept
      invitation = Invitation.find_by(token: params[:token])
      if invitation
        user = invitation.organization.accept_invitation(invitation.token, params[:password])
        if user
          start_new_session_for(user)
          redirect_to root_path, notice: "Welcome to the team!"
        else
          flash[:alert] = "Something went wrong"
          render :accept
        end
      else
        redirect_to root_path, alert: "Invalid token"
      end
    end
  end
  