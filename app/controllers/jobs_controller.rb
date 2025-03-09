class JobsController < ApplicationController
  before_action :set_organization_and_property, only: [:new, :create, :index]
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
      redirect_to organization_property_jobs_path(@organization, @property), notice: "Job created successfully."
    else
      puts @job.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_organization_and_property
    @organization = Organization.find(params[:organization_id])
    @property = @organization.properties.find(params[:property_id])
  end

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:date, :checklist_id)
  end
end