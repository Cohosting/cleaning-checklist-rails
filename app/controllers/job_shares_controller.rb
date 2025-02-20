class JobSharesController < ApplicationController
  def show
    @job = Job.find_by(public_token: params[:public_token])
    if @job
      render :show
    else
      render plain: "Job not found", status: :not_found
    end
  end
end
