class JobSharesController < ApplicationController
  allow_unauthenticated_access
  def show
    @job = Job.find_by!(public_token: params[:public_token])
    
    # Only load job sections if the job is not in "scheduled" status
    if @job.status != "scheduled"
      @job_sections = @job.job_sections.includes(
        job_section_groups: {
          job_tasks: { images_attachments: :blob }
        }
      ).order(:position)
    end

    if @job
      render :show
    else
      render plain: "Job not found", status: :not_found
    end
  end
end
