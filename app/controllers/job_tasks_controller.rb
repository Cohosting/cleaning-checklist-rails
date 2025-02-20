class JobTasksController < ApplicationController
  before_action :set_job
  before_action :set_job_task, only: [:update]

  def create
    @job_task = @job.job_tasks.build(create_job_task_params)

    if @job_task.save
      redirect_to property_job_path(@job.property, @job), notice: "Task added successfully."
    else
      redirect_to property_job_path(@job.property, @job), alert: "Failed to add task."
    end
  end

  def update
    if @job_task.update(job_task_params)
      redirect_to property_job_path(@job.property, @job), notice: "Task updated."
    else
      redirect_to property_job_path(@job.property, @job), alert: "Task update failed."
    end
  end

def remove_image
  # Ensure image_id is present in params
  if params[:image_id].present?
    image = @job_task.images.find(params[:image_id])
    image.purge
    redirect_to property_job_path(@job_task.job.property, @job_task.job), notice: "Image removed successfully."
  else
    redirect_to property_job_path(@job_task.job.property, @job_task.job), alert: "No image found to remove."
  end
end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def set_job_task
    @job_task = @job.job_tasks.find(params[:id])
  end

  def job_task_params
    params.require(:job_task).permit(:completed, images: [])
  end

  def create_job_task_params
    params.permit(:name)
  end
end