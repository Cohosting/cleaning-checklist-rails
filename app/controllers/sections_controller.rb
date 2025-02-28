# app/controllers/sections_controller.rb
class SectionsController < ApplicationController
  before_action :set_organization
  before_action :set_checklist
  before_action :set_section, only: [:update, :destroy]

  def create
    @section = @checklist.sections.build(section_params)

    respond_to do |format|
      if @section.save
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.append("checklist_sections", partial: "sections/section", locals: { 
              section: @section, 
              checklist: @checklist,
              organization: @organization 
            }),
            turbo_stream.update("new_section_form", partial: "sections/form", locals: { 
              checklist: @checklist, 
              section: Section.new,
              organization: @organization 
            }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Section added!", type: "success" })
          ]
        }
        format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Section added!" }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update("new_section_form", partial: "sections/form", locals: { 
            checklist: @checklist, 
            section: @section,
            organization: @organization 
          })
        }
        format.html { redirect_to organization_checklist_path(@organization, @checklist) }
      end
    end
  end

  def update
    respond_to do |format|
      if @section.update(section_params)
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.replace(@section, partial: "sections/section", locals: { 
              section: @section, 
              checklist: @checklist,
              organization: @organization 
            }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Section updated!", type: "success" })
          ]
        }
        format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Section updated!" }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("section_#{@section.id}_form", partial: "sections/form", locals: { 
            checklist: @checklist, 
            section: @section,
            organization: @organization 
          })
        }
        format.html { redirect_to organization_checklist_path(@organization, @checklist) }
      end
    end
  end

  def destroy
    @section.destroy
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: [
          turbo_stream.remove(@section),
          turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Section deleted!", type: "success" })
        ]
      }
      format.html { redirect_to organization_checklist_path(@organization, @checklist), notice: "Section deleted!" }
    end
  end

  def move
    # Handle reordering of sections
    params[:section_order]&.each_with_index do |id, index|
      @checklist.sections.find(id).update(position: index + 1)
    end
    
    head :ok
  end

  private
  
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end
  
  def set_checklist
    @checklist = @organization.checklists.find(params[:checklist_id])
  end
  
  def set_section
    @section = @checklist.sections.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:title)
  end
end