# app/controllers/job_assignments_controller.rb
class JobAssignmentsController < ApplicationController
  before_action :set_job, only: [:create]
  before_action :set_job_assignment, only: [:destroy]
  
  def create
    @job_assignment = @job.job_assignments.new(job_assignment_params)
    @job_assignment.assigned_by = Current.user
    
    authorize @job_assignment
    
    respond_to do |format|
      if @job_assignment.save
        format.html { redirect_to organization_property_jobs_path(@job.organization, @job.property), notice: "Job assigned to subcontractor." }
        format.turbo_stream { 
          flash.now[:notice] = "Job assigned to subcontractor."
          render turbo_stream: [
            turbo_stream.replace("flash", partial: "layouts/flash"),
            turbo_stream.replace("job_#{@job.id}", partial: "jobs/job", locals: { job: @job, organization: @job.organization, property: @job.property })
          ]
        }
      else
        format.html { 
          redirect_to organization_property_jobs_path(@job.organization, @job.property), 
          alert: "Error: #{@job_assignment.errors.full_messages.join(', ')}" 
        }
        format.turbo_stream {
          flash.now[:alert] = "Error: #{@job_assignment.errors.full_messages.join(', ')}"
          render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash")
        }
      end
    end
  end
  
  def destroy
    authorize @job_assignment
    job = @job_assignment.job
    @job_assignment.destroy
    
    respond_to do |format|
      format.html { redirect_to organization_property_jobs_path(job.organization, job.property), notice: "Assignment removed." }
      format.turbo_stream { 
        flash.now[:notice] = "Assignment removed."
        render turbo_stream: [
          turbo_stream.replace("flash", partial: "layouts/flash"),
          turbo_stream.replace("job_#{job.id}", partial: "jobs/job", locals: { job: job, organization: job.organization, property: job.property })
        ]
      }
    end
  end
  
  private
  
  def set_job
    @job = Job.find(params[:job_id])
  end
  
  def set_job_assignment
    @job_assignment = JobAssignment.find(params[:id])
  end
  
  def job_assignment_params
    params.require(:job_assignment).permit(:subcontractor_id, :notes)
  end
end