class UpsellsController < ApplicationController
  include StripeCheckout

  before_action :set_property
  before_action :set_upsell, only: %i[show edit update destroy checkout]

  # GET /properties/:property_id/upsells
  def index
    @upsells = @property.upsells
  end

  # GET /properties/:property_id/upsells/1
  def show
  end

  # GET /properties/:property_id/upsells/new
  def new
    @upsell = @property.upsells.new
  end

  # GET /properties/:property_id/upsells/1/edit
  def edit
  end

  # POST /properties/:property_id/upsells
  def create
    @upsell = @property.upsells.new(upsell_params)

    respond_to do |format|
      if @upsell.save
        format.html { redirect_to property_upsell_path(@property, @upsell), notice: "Upsell was successfully created." }
        format.json { render :show, status: :created, location: property_upsell_path(@property, @upsell) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @upsell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /properties/:property_id/upsells/1
  def update
    respond_to do |format|
      if @upsell.update(upsell_params)
        format.html { redirect_to property_upsell_path(@property, @upsell), notice: "Upsell was successfully updated." }
        format.json { render :show, status: :ok, location: property_upsell_path(@property, @upsell) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @upsell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/:property_id/upsells/1
  def destroy
    @upsell.destroy!
    respond_to do |format|
      format.html { redirect_to property_upsells_path(@property), status: :see_other, notice: "Upsell was successfully deleted." }
      format.json { head :no_content }
    end
  end

  # POST /properties/:property_id/upsells/1/checkout
  def checkout
    session = create_checkout_session(@upsell)
    @upsell.update(stripe_checkout_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    flash[:error] = "Payment error: #{e.message}"
    redirect_to property_upsell_path(@property, @upsell)
  end

  private

  # Find Property from Nested Route
  def set_property
    @property = Property.find(params[:property_id])
  end

  # Find Upsell Belonging to Property
  def set_upsell
    @upsell = @property.upsells.find(params[:id])
  end

  # Strong Params: Allow Only Permitted Fields
  def upsell_params
    params.require(:upsell).permit(:title, :description, :price)
  end
end
