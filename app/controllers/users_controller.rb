class UsersController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]

  def new
    @user = User.new
    @invitation = Invitation.find_by(token: params[:token]) if params[:token]
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.new(user_params)

      if @user.save
        # Handle invited users
        if params[:token].present?
          invitation = Invitation.find_by(token: params[:token])
          if invitation
            invitation.organization.memberships.create!(user: @user, role: "cleaner")
            invitation.destroy # Remove used invitation
          end
        end

        # Log in the user after signup
        start_new_session_for(@user)
        redirect_to root_path, notice: "Welcome, #{@user.email_address}!"
      else
        flash[:alert] = "Please fix the errors below."
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = "Something went wrong, please try again."
    render :new, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password)
  end
end
