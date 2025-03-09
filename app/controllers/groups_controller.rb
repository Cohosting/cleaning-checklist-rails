# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_organization
  before_action :set_group, only: [:edit, :update, :destroy]

  def index
    @groups = @organization.groups
    @new_group = @organization.groups.build
  end

  def new
    @group = @organization.groups.build
  end

  def create
    @group = @organization.groups.build(group_params)
  
    respond_to do |format|
      if @group.save
        format.html { redirect_to organization_groups_path(@organization), notice: "Group created!" }
        format.json { render json: @group }
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.append("groups", partial: "groups/group", locals: { group: @group, organization: @organization }),
            turbo_stream.update("new_group", partial: "groups/form", locals: { organization: @organization, group: Group.new }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Group created!", type: "success" })
          ]
        }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update("new_group", partial: "groups/form", locals: { organization: @organization, group: @group })
        }
      end
    end
  end
  def edit
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.replace(@group, partial: "groups/group", locals: { group: @group, organization: @organization }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Group updated!", type: "success" })
          ]
        }
        format.html { redirect_to organization_groups_path(@organization), notice: "Group updated!" }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("group_#{@group.id}_form", partial: "groups/form", locals: { organization: @organization, group: @group })
        }
        format.html { render :edit }
      end
    end
  end

   

  private
  
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end
  
  def set_group
    @group = @organization.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end
end