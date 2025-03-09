# app/controllers/property_groups_controller.rb
class PropertyGroupsController < ApplicationController
    before_action :set_property
    
    def new
      @property_group = @property.property_groups.new
      @available_groups = @property.organization.groups.where.not(
        id: @property.property_groups.pluck(:group_id)
      )
    end
    
    def create
      @property_group = @property.property_groups.new(property_group_params)
      @available_groups = @property.organization.groups.where.not(
        id: @property.property_groups.pluck(:group_id)
      )
      
      respond_to do |format|
        if @property_group.save
          @group = @property_group.group
          format.turbo_stream
          format.html { redirect_to organization_property_path(@property.organization, @property), notice: "Area added successfully" }
        else
          # Add this check to prevent further errors in case group_id was invalid
          if @property_group.group_id.present?
            @available_groups = @available_groups.or(@property.organization.groups.where(id: @property_group.group_id))
          end
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @property_group = @property.property_groups.find(params[:id])
      @property_group.destroy
      redirect_to organization_property_path(@property.organization, @property),
                  notice: "Area removed successfully"
    end
    
    private
    
    def set_property
      @organization = Organization.find(params[:organization_id])
      @property = @organization.properties.find(params[:property_id])
    end
    
    def property_group_params
      params.require(:property_group).permit(:group_id, :quantity)
    end
  end