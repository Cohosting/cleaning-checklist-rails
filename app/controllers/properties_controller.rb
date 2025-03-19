class PropertiesController < ApplicationController
  before_action :set_organization
  before_action :set_property, only: %i[ show edit update destroy make_default_checklist ]
  
  # Add Pundit authorization checks
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /organizations/:organization_id/properties
  def index
    # Use policy_scope to filter properties
    @properties = policy_scope(@organization.properties)
  end

  # GET /organizations/:organization_id/properties/:id
  def show
    authorize @property
  end

  # GET /organizations/:organization_id/properties/new
  def new
    @property = @organization.properties.new
    authorize @property
  end

  # GET /organizations/:organization_id/properties/:id/edit
  def edit
    authorize @property
  end

  # POST /organizations/:organization_id/properties
  def create
    @property = @organization.properties.new(property_params)
    authorize @property

    respond_to do |format|
      if @property.save
        format.html { redirect_to organization_property_path(@organization, @property), notice: "Property was successfully created." }
        format.json { render :show, status: :created, location: organization_property_path(@organization, @property) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/:organization_id/properties/:id
  def update
    authorize @property
    respond_to do |format|
      if @property.update(property_params)
        format.html { redirect_to organization_property_path(@organization, @property), notice: "Property was successfully updated." }
        format.json { render :show, status: :ok, location: organization_property_path(@organization, @property) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/:organization_id/properties/:id
  def destroy
    authorize @property
    @property.destroy!
    respond_to do |format|
      format.html { redirect_to organization_properties_path(@organization), status: :see_other, notice: "Property was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def make_default_checklist
    authorize @property, :update?
    @checklist = Checklist.find(params[:checklist_id])
  
    if @property.update(default_checklist: @checklist)
      redirect_to organization_property_checklists_path(@organization, @property), notice: "Default checklist updated!"
    else
      redirect_to organization_property_checklists_path(@organization, @property), alert: "Failed to update default checklist."
    end
  end

  private

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    def set_property
      @property = Property.find(params[:id])
    end

    def property_params
      params.require(:property).permit(:name, :address)
    end
end