class UpsellsController < ApplicationController
  include StripeCheckout

  before_action :set_organization
  before_action :set_upsell, only: %i[show edit update destroy checkout edit_properties update_properties]

  # GET /organizations/:organization_id/upsells
  def index
    @upsells = @organization.upsells
  end

  # GET /organizations/:organization_id/upsells/1
  def show
  end

  # GET /organizations/:organization_id/upsells/new
  def new
    @upsell = @organization.upsells.new
  end

  # GET /organizations/:organization_id/upsells/1/edit
  def edit
  end

  # POST /organizations/:organization_id/upsells
  def create
    @upsell = @organization.upsells.new(upsell_params)

    respond_to do |format|
      if @upsell.save
        format.html { redirect_to organization_upsell_path(@organization, @upsell), notice: "Upsell was successfully created." }
        format.json { render :show, status: :created, location: organization_upsell_path(@organization, @upsell) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @upsell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/:organization_id/upsells/1
  def update
    respond_to do |format|
      if @upsell.update(upsell_params)
        format.html { redirect_to organization_upsell_path(@organization, @upsell), notice: "Upsell was successfully updated." }
        format.json { render :show, status: :ok, location: organization_upsell_path(@organization, @upsell) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @upsell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/:organization_id/upsells/1
  def destroy
    @upsell.destroy!
    respond_to do |format|
      format.html { redirect_to organization_upsells_path(@organization), status: :see_other, notice: "Upsell was successfully deleted." }
      format.json { head :no_content }
    end
  end

  # POST /organizations/:organization_id/upsells/1/checkout
  def checkout
    ActiveRecord::Base.transaction do
      session = create_checkout_session(@upsell)
      @upsell.update!(stripe_checkout_session_id: session.id)
    end
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    flash[:error] = "Payment error: #{e.message}"
    redirect_to organization_upsell_path(@organization, @upsell)
  end

  def edit_properties
    @properties = Property.order(:name)
    @properties = @properties.search(params[:search]) if params[:search].present?
    @selected_property_ids = @upsell.property_ids
    
    respond_to do |format|
      format.html
      format.js # For AJAX pagination and search
    end
  end
  
  def update_properties
    @upsell.properties = params[:property_ids].present? ? Property.where(id: params[:property_ids]) : []
    
    redirect_to   edit_properties_organization_upsell_path(@organization, @upsell), notice: "Upsell properties updated."
  end
  def reorder
    # Get the parameters
    upsell_id = params[:id]
    new_position = params[:position].to_i
    
    # Find the upsell
    upsell = @organization.upsells.find(upsell_id)
    
    # Update the position
    upsell.insert_at(new_position)
    
    # Return a success response
    head :ok
  end

  private

  # Find Organization from Nested Route
  def set_organization
    @organization =  Organization.includes(:upsells).find(params[:organization_id])
                 
  end 

  # Find Upsell Belonging to Organization
  def set_upsell
    @upsell = @organization.upsells.find(params[:id])
    puts @upsell.inspect
  end

  # Strong Params: Allow Only Permitted Fields
  def upsell_params
    params.require(:upsell).permit(:title, :description, :price)
  end
end

