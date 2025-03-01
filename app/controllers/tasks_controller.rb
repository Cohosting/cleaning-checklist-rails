# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_organization
  before_action :set_checklist
  before_action :set_section
  before_action :set_section_group
  before_action :set_task, only: [:update, :destroy, :toggle]

  def create
    @task = @section_group.tasks.build(task_params)
  
    respond_to do |format|
      if @task.save
        format.turbo_stream
        format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Task added!" }
      else
        format.turbo_stream
        format.html { redirect_to organization_checklist_path(@organization, @checklist) }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.turbo_stream
        format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Task updated!" }
      else
        format.turbo_stream
        format.html { redirect_to organization_checklist_path(@organization, @checklist) }
      end
    end
  end

  def toggle
    @task.update(completed: !@task.completed)
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to organization_checklist_path(@organization, @checklist) }
    end
  end

  def destroy
    @task.destroy
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Task deleted!" }
    end
  end

  def move
    @task = Task.find(params[:id])
    @original_section_group = @task.section_group
    
    if params[:section_group_id].present?
      target_section_group_id = params[:section_group_id].to_i
      @target_section_group = SectionGroup.find(target_section_group_id)
      position = params[:position].present? ? params[:position].to_i : 1
      
      # Calculate empty states changes
      @original_is_empty = @original_section_group.tasks.count == 1 && 
                          @original_section_group.id != target_section_group_id
      @target_was_empty = @target_section_group.tasks.count == 0
      
      # Update the task
      @task.update(section_group_id: target_section_group_id, position: position)
      
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { success: true, message: "Task moved successfully" } }
      end
    else
      render json: { success: false, message: "No section group specified" }
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end
  
  private
  
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end
  
  def set_checklist
    @checklist = @organization.checklists.find(params[:checklist_id])
  end
  
  def set_section
    @section = @checklist.sections.find(params[:section_id])
  end
  
  def set_section_group
    # Try to find section group in the current section first
    @section_group = @section.section_groups.find_by(id: params[:section_group_id])
    
    # If not found (might have been moved), find it directly and update section
    if @section_group.nil?
      @section_group = SectionGroup.find(params[:section_group_id])
      @section = @section_group.section # Update the section reference to match the section_group
    end
  end
  
  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:content, :completed)
  end
   
  def reorder_tasks(section_group)
    # Get all tasks for this section group ordered by position
    tasks = section_group.tasks.order(:position).to_a
    
    # Update positions to ensure they are sequential
    tasks.each_with_index do |task, index|
      new_position = index + 1
      if task.position != new_position
        task.update_column(:position, new_position)
      end
    end
  end
end