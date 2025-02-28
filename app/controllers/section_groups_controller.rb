# app/controllers/section_groups_controller.rb
class SectionGroupsController < ApplicationController

  include ActionView::RecordIdentifier

  
  before_action :set_organization
  before_action :set_checklist
  before_action :set_section
  before_action :set_section_group, only: [:destroy]

  def create
    @group = @organization.groups.find(params[:group_id])
    @section_group = @section.section_groups.build(group: @group)
  
    respond_to do |format|
      if @section_group.save
        format.turbo_stream { 
          render turbo_stream: [
            # Use the same dom_id helper to generate matching ID
            turbo_stream.append(dom_id(@section, :groups), 
                               partial: "section_groups/section_group", 
                               locals: { 
                                 section_group: @section_group, 
                                 organization: @organization,
                                 checklist: @checklist,
                                 section: @section
                               }),
            turbo_stream.prepend("flash_messages", 
                               partial: "shared/flash", 
                               locals: { message: "Group added to section!", type: "success" })
          ]
        }
        format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Group added to section!" }
        format.json { render json: { success: true } }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.prepend("flash_messages", 
                                                   partial: "shared/flash", 
                                                   locals: { message: "Could not add group to section!", type: "error" })
        }
        format.html { redirect_to organization_checklist_path(@organization, @checklist), alert: "Could not add group to section!" }
        format.json { render json: { success: false, errors: @section_group.errors.full_messages } }
      end
    end
  end
  def destroy
    @section_group.destroy
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: [
          turbo_stream.remove(@section_group),
          turbo_stream.update("section_#{@section.id}_add_group", partial: "section_groups/form", locals: { 
            organization: @organization,
            checklist: @checklist,
            section: @section,
            available_groups: @organization.groups.where.not(id: @section.groups.pluck(:id))
          }),
          turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Group removed from section!", type: "success" })
        ]
      }
      format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Group removed from section!" }
    end
  end

  def move
    # Handle reordering of groups within a section
    params[:group_order]&.each_with_index do |id, index|
      @section.section_groups.find(id).update(position: index + 1)
    end
    
    head :ok
  end
 def move_to_section
  begin
    @section_group = @section.section_groups.find(params[:id])
    @target_section = @checklist.sections.find(params[:target_section_id])
    
    # Debug info
    Rails.logger.info("Moving section_group #{@section_group.id} to section #{@target_section.id}")
    
    # Check if the group already exists in the target section
    existing_group = @target_section.section_groups.find_by(group_id: @section_group.group_id)
    
    if existing_group
      # If the group already exists in target section, move tasks instead of the group
      @section_group.tasks.update_all(section_group_id: existing_group.id)
      @section_group.destroy
      
      render json: { success: true, message: "Tasks moved to existing group in target section" }
    else
      # Update the section_group to belong to the new section
      if @section_group.update(section: @target_section, position: params[:position])
        render json: { success: true, message: "Group moved to different section" }
      else
        render json: { success: false, errors: @section_group.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue => e
    Rails.logger.error("Error in move_to_section: #{e.message}")
    render json: { success: false, error: e.message }, status: :internal_server_error
  end
end
def new_task_form
  @organization = Organization.find(params[:organization_id])
  @checklist = @organization.checklists.find(params[:checklist_id])
  @section = @checklist.sections.find(params[:section_id])
  
  # Use params[:id] instead of params[:section_group_id]
  # This is because member routes use :id as the parameter name
  @section_group = SectionGroup.find(params[:id])
  
  # Ensure the section group belongs to the section
  unless @section_group.section_id == @section.id
    # If not, update it to match the current section
    @section_group.update(section_id: @section.id)
  end
  
  @task = Task.new
  
  render partial: "tasks/form", locals: { 
    organization: @organization, 
    checklist: @checklist, 
    section: @section, 
    section_group: @section_group, 
    task: @task 
  }
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
    @section_group = @section.section_groups.find(params[:id])
  end
end