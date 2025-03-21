# app/controllers/my_jobs_controller.rb
class MyJobsController < ApplicationController
    before_action :require_login
    before_action :set_job, only: [:show, :assign_subcontractor, :remove_subcontractor]
    
    def index
      # Load all jobs associated with current user with necessary associations
      @jobs = Current.user.associated_jobs 
    end
    
    def show
      # Check if current user has access to this job
      unless @job.assigned_to?(Current.user)
        flash[:alert] = "You don't have access to that job"
        redirect_to my_jobs_path
        return
      end
      
      @property = @job.property
      @job_sections = @job.job_sections.includes(job_section_groups: :job_tasks)
    end
    
    # POST /my_jobs/:id/assign_subcontractor
    def assign_subcontractor
      # Ensure the user has permission to assign subcontractors
      unless @job.assigned_to&.user_id == Current.user.id
        flash[:alert] = "You don't have permission to assign subcontractors to this job"
        redirect_to my_jobs_path
        return
      end
      
      subcontractor = User.find(params[:subcontractor_id])
      
      # Check if the subcontractor is actually a subcontractor of the current user
      unless Current.user.subcontractors.include?(subcontractor)
        flash[:alert] = "This user is not your subcontractor"
        redirect_to my_jobs_path
        return
      end
      
      # Create the assignment
      assignment = @job.job_assignments.build(
        subcontractor: subcontractor,
        assigned_by: Current.user,
        notes: params[:notes]
      )
      
      if assignment.save
        flash[:notice] = "Subcontractor assigned successfully"
      else
        flash[:alert] = "Failed to assign subcontractor: #{assignment.errors.full_messages.join(', ')}"
      end
      
      redirect_to my_jobs_path
    end
    
    # DELETE /my_jobs/:id/remove_subcontractor
    def remove_subcontractor
      # Ensure the user has permission to remove subcontractors
      unless @job.assigned_to&.user_id == Current.user.id
        flash[:alert] = "You don't have permission to remove subcontractors from this job"
        redirect_to my_jobs_path
        return
      end
      
      assignment = @job.job_assignments.find_by(subcontractor_id: params[:subcontractor_id])
      
      if assignment.nil?
        flash[:alert] = "Subcontractor assignment not found"
      elsif assignment.destroy
        flash[:notice] = "Subcontractor removed successfully"
      else
        flash[:alert] = "Failed to remove subcontractor"
      end
      
      redirect_to my_jobs_path
    end
    
    private
    
    def set_job
      @job = Job.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Job not found"
      redirect_to my_jobs_path
    end
    
    def require_login
      unless Current.user
        flash[:alert] = "You must be logged in to access this page"
        redirect_to login_path
      end
    end
  end