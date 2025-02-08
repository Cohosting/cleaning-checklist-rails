class PropertiesController < ApplicationController
  before_action :set_property, only: %i[ show edit update destroy make_default_checklist ]

  # GET /properties or /properties.json
  def index
    @properties = Property.all
  end

  # GET /properties/1 or /properties/1.json
  def show
  end

  # GET /properties/new
  def new
    @property = Property.new
  end

  # GET /properties/1/edit
  def edit
  end

  # POST /properties or /properties.json
  def create
    @property = Property.new(property_params)

    respond_to do |format|
      if @property.save
        format.html { redirect_to @property, notice: "Property was successfully created." }
        format.json { render :show, status: :created, location: @property }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /properties/1 or /properties/1.json
  def update
    respond_to do |format|
      if @property.update(property_params)
        format.html { redirect_to @property, notice: "Property was successfully updated." }
        format.json { render :show, status: :ok, location: @property }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1 or /properties/1.json
  def destroy
    @property.destroy!

    respond_to do |format|
      format.html { redirect_to properties_path, status: :see_other, notice: "Property was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  def make_default_checklist
   puts "make_default_checklist"
   puts "params: #{params.inspect}" 
   puts "params[:checklist_id]: #{params[:checklist_id]}"
     @checklist = Checklist.find(params[:checklist_id])
  
    if @property.update(default_checklist: @checklist)
      redirect_to property_checklists_path(@property), notice: "Default checklist updated!"
    else
      redirect_to property_checklists_path(@property), alert: "Failed to update default checklist."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_property
      @property = Property.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def property_params
      params.expect(property: [ :name, :address, :checklist_id ])
    end
end
