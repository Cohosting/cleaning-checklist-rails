class DashboardController < ApplicationController
  def index
    @properties = Property.includes(:checklists)
  end
end
