# app/controllers/jobs_controller.rb
class JobsController < ApplicationController
  before_action :set_organization_and_property, only: [:new, :create, :index]
  before_action :set_job_with_associations, only: [:show, :take_snapshot]
  # Add authorization check if you have a system like Pundit or CanCanCan
  # before_action :authorize_job, only: [:show, :take_snapshot]

  def index
    @jobs = @property.jobs.includes(:property)
  end

  def show
    if @job.snapshot_at.present?
      # If job has a snapshot, load job sections and related data
      @job_sections = @job.job_sections.includes(
        job_section_groups: {
          job_tasks: { images_attachments: :blob }
        }
      ).order(:position)
    else
      # Load checklist with all relations for template display
      @checklist = Checklist.includes(
        sections: { 
          section_groups: {
            group: {},
            tasks: {}
          }
        }
      ).find(@job.checklist_id)
      
      # Load property groups with full objects to access quantity
      @property_groups = PropertyGroup.where(property_id: @job.property_id).index_by(&:group_id)
    end
  end

  def new
    @job = @property.jobs.build
    @checklists = @organization.checklists.includes(:sections)
  end

  def create
    service = JobCreationService.new(
      property_id: @property.id,
      checklist_id: job_params[:checklist_id],
      date: job_params[:date]
    )
    
    begin
      @job = service.call
      redirect_to organization_property_jobs_path(@organization, @property), notice: "Job created successfully."
    rescue StandardError => e
      # Log the error for debugging
      Rails.logger.error("Job creation failed: #{e.message}")
      
      @job = @property.jobs.build(job_params)
      @checklists = @organization.checklists.includes(:sections)
      flash.now[:alert] = "Failed to create job: #{e.message}"
      render :new, status: :unprocessable_entity
    end
  end

  # Action to take a snapshot of the checklist
  def take_snapshot
    ActiveRecord::Base.transaction do
      @job.update!(snapshot_at: Time.current, status: :in_progress)
    end
    
    redirect_to organization_property_job_path(@job.property.organization, @job.property, @job), 
                notice: "Job started successfully."
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Failed to start job: #{e.message}"
    redirect_to organization_property_job_path(@job.property.organization, @job.property, @job)
  end

  private

  def set_organization_and_property
    @organization = Organization.find(params[:organization_id])
    @property = @organization.properties.find(params[:property_id])
  end

  def set_job_with_associations
    @job = Job.includes(property: :organization).find(params[:id])
  end

  def job_params
    params.require(:job).permit(:date, :checklist_id)
  end
end