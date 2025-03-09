class DashboardController < ApplicationController
  before_action :set_user

  def index
    @organization = Organization.includes(:properties).find(@user.organization.id)
    puts @organization.inspect
    
    @properties = @organization.properties
  end

  private

  def set_user 
    @user = Current.user
  end
end
