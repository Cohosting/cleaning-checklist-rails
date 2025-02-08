class JobsController < ApplicationController
  before_action :set_property, only: [:new, :create, :index]
  before_action :set_job, only: [:show]

  def index
    @jobs = @property.jobs
  end

  def show
  end

  def new
    @job = @property.jobs.build
  end

  def create
    @job = @property.jobs.build(job_params)
    if @job.save
      redirect_to property_jobs_path(@property), notice: "Job created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:date, :checklist_id)
  end
end
