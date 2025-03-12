# class JobTasksController < ApplicationController
#   before_action :set_job
#   before_action :set_job_task, only: [:update]

#   def create
#     @job_task = @job.job_tasks.build(create_job_task_params)

#     if @job_task.save
#       redirect_to property_job_path(@job.property, @job), notice: "Task added successfully."
#     else
#       redirect_to property_job_path(@job.property, @job), alert: "Failed to add task."
#     end
#   end

#   def update
#     if @job_task.update(job_task_params)
#       respond_to do |format|
#         format.html { redirect_back(fallback_location: root_path, notice: "Task updated.") }
#         format.json { render json: { status: "success", completed: @job_task.completed } }
#       end
#     else
#       respond_to do |format|
#         format.html { redirect_back(fallback_location: root_path, alert: "Failed to update task.") }
#         format.json { render json: { status: "error", message: @job_task.errors.full_messages.join(", ") } }
#       end
#     end
#   end


# def remove_image
#   # Ensure image_id is present in params
#   if params[:image_id].present?
#     image = @job_task.images.find(params[:image_id])
#     image.purge
#     redirect_to property_job_path(@job_task.job.property, @job_task.job), notice: "Image removed successfully."
#   else
#     redirect_to property_job_path(@job_task.job.property, @job_task.job), alert: "No image found to remove."
#   end
# end

#   private

#   def set_job
#     @job = Job.find(params[:job_id])
#   end

#   def set_job_task
#     @job_task = @job.job_tasks.find(params[:id])
#   end

#   def job_task_params
#     params.require(:job_task).permit(:completed, images: [])
#   end

#   def create_job_task_params
#     params.permit(:name)
#   end
# end

# app/controllers/job_tasks_controller.rb
class JobTasksController < ApplicationController
  before_action :set_organization
  before_action :set_property
  before_action :set_job
  before_action :set_job_task, only: [:update, :remove_image, :upload_images]

  def update
    # If trying to mark as completed but images are required and none are attached
    if params[:job_task][:completed] == "1" && @job_task.image_required? && !@job_task.images.attached?
      puts "Cannot complete task requiring images with no images attached"
      respond_to do |format|
        format.html { 
          redirect_back(fallback_location: root_path, alert: "Cannot complete this task. Images are required but none have been uploaded.") 
        }
        format.json { 
          render json: { status: "error", message: "Cannot complete this task. Images are required but none have been uploaded." } 
        }
      end
      return
    end
    
    if @job_task.update(job_task_params)
      puts "Update succeeded! New job task state: #{@job_task.reload.inspect}"
      respond_to do |format|
        format.html { 
          redirect_back(fallback_location: root_path, notice: "Task updated.") 
        }
        format.json { 
          render json: { status: "success", completed: @job_task.completed } 
        }
      end
    else
      puts "Update FAILED! Errors: #{@job_task.errors.full_messages}"
      respond_to do |format|
        format.html { 
          redirect_back(fallback_location: root_path, alert: "Failed to update task.") 
        }
        format.json { 
          render json: { status: "error", message: @job_task.errors.full_messages.join(", ") } 
        }
      end
    end
  end

  def upload_images
    if params[:images].present?
      # Attach each uploaded image to the job task
      params[:images].each do |image|
        @job_task.images.attach(image)
      end
      
      puts "Images uploaded successfully to job task: #{@job_task.id}"
      redirect_back(fallback_location: organization_property_job_path(@organization, @property, @job), 
                   notice: "Images uploaded successfully.")
    else
      puts "Image upload failed: No images provided"
      redirect_back(fallback_location: organization_property_job_path(@organization, @property, @job), 
                   alert: "No images selected for upload.")
    end
  end

  def remove_image
    if params[:image_id].present?
      image = @job_task.images.find(params[:image_id])
      image.purge
      redirect_to organization_property_job_path(@organization, @property, @job), notice: "Image removed successfully."
    else
      redirect_to organization_property_job_path(@organization, @property, @job), alert: "No image found to remove."
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_property
    @property = @organization.properties.find(params[:property_id])
  end

  def set_job
    @job = @property.jobs.find(params[:job_id])
  end

  def set_job_task
    @job_task = @job.job_tasks.find(params[:id])
  end

  def job_task_params
    params.require(:job_task).permit(:completed, images: [])
  end
end