class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 1000, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    if params[:invitation_token]
      @invitation = Invitation.find_by(token: params[:invitation_token])
      if @invitation
        @email_address = @invitation.email
      else
        flash[:alert] = "Invalid invitation token."
        redirect_to root_path and return
      end
    end
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      start_new_session_for user
      if params[:invitation_token].present?
        redirect_to accept_invitations_path(token: params[:invitation_token])
      else
        redirect_to root_path, notice: "Signed in successfully."
      end
    else
      flash.now[:alert] = "Try another email address or password."
      render :new, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    redirect_to signin_path, notice: "Signed out successfully."
  end
end