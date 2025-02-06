class ChecklistsController < ApplicationController
    before_action :set_property
    before_action :set_checklist, only: [:show, :update, :destroy]
  
    def index
      @checklists = @property.checklists
    end
  
    def show
    end
  
    def new
      @checklist = @property.checklists.build
    end
  
    def create
      @checklist = @property.checklists.build(checklist_params)
      if @checklist.save
        redirect_to property_checklists_path(@property), notice: 'Checklist created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def update
      if @checklist.update(checklist_params)
        redirect_to property_checklist_path(@property, @checklist), notice: 'Checklist updated.'
      else
        render :show, status: :unprocessable_entity
      end
    end
  
    def destroy
      @checklist.destroy
      redirect_to property_checklists_path(@property), notice: 'Checklist deleted.'
    end
  
    private
  
    def set_property
      @property = Property.find(params[:property_id])
    end
  
    def set_checklist
      @checklist = @property.checklists.find(params[:id])
    end
  
    def checklist_params
      params.require(:checklist).permit(:name, :completed)
    end
  end
  