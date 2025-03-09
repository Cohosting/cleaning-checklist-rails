class ChecklistsController < ApplicationController
  before_action :set_organization
   before_action :set_checklist, only: [:show, :edit, :update, :destroy]

  def index
    @checklists = @organization.checklists
    @new_checklist = @organization.checklists.build
  end

  def show
    @sections = @checklist.sections.includes(section_groups: :tasks)
    @new_section = @checklist.sections.build
  end

  def new
    @checklist = @organization.checklists.build
  end

  def create
    @checklist = @organization.checklists.build(checklist_params)
    @checklist.organization = @organization  # Ensuring `organization_id` is assigned

    respond_to do |format|
      if @checklist.save
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.append("checklists", partial: "checklists/checklist", locals: { checklist: @checklist, organization: @organization, property: @property }),
            turbo_stream.update("new_checklist", partial: "checklists/form", locals: { checklist: @organization.checklists.build, organization: @organization, property: @property }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Checklist created!", type: "success" })
          ]
        }
        format.html { redirect_to organization_property_checklists_path(@organization, @property), notice: "Checklist created!" }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update("new_checklist", partial: "checklists/form", locals: { checklist: @checklist, organization: @organization, property: @property })
        }
        format.html { render :new }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @checklist.update(checklist_params)
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.replace(@checklist, partial: "checklists/checklist", locals: { checklist: @checklist, property: @property }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Checklist updated!", type: "success" })
          ]
        }
        format.html { redirect_to organization_property_checklist_path(@organization, @property, @checklist), notice: "Checklist updated!" }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("checklist_#{@checklist.id}_form", partial: "checklists/form", locals: { checklist: @checklist, property: @property })
        }
        format.html { render :edit }
      end
    end
  end

  def destroy
    @checklist.destroy
    
    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: [
          turbo_stream.remove(@checklist),
          turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Checklist deleted!", type: "success" })
        ]
      }
      format.html { redirect_to organization_property_checklists_path(@organization, @property), notice: "Checklist deleted!" }
    end
  end

  private
  
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

   
  
  def set_checklist
    @checklist = @organization.checklists.find(params[:id])
  end

  def checklist_params
    params.require(:checklist).permit(:name, :completed, :title, :description, :organization_id, :property_id)
  end
end
