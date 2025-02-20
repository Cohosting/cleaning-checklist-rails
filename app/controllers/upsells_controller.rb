class UpsellsController < ApplicationController
 
  include StripeCheckout

 
  before_action :set_upsell, only: %i[ show edit update destroy ]

  # GET /upsells or /upsells.json
  def index
    @upsells = Upsell.all
  end

  # GET /upsells/1 or /upsells/1.json
  def show
  end

  # GET /upsells/new
  def new
    @upsell = Upsell.new
  end

  # GET /upsells/1/edit
  def edit
  end

  # POST /upsells or /upsells.json
  def create
    @upsell = Upsell.new(upsell_params)

    respond_to do |format|
      if @upsell.save
        format.html { redirect_to @upsell, notice: "Upsell was successfully created." }
        format.json { render :show, status: :created, location: @upsell }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @upsell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /upsells/1 or /upsells/1.json
  def update
    respond_to do |format|
      if @upsell.update(upsell_params)
        format.html { redirect_to @upsell, notice: "Upsell was successfully updated." }
        format.json { render :show, status: :ok, location: @upsell }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @upsell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /upsells/1 or /upsells/1.json
  def destroy
    @upsell.destroy!

    respond_to do |format|
      format.html { redirect_to upsells_path, status: :see_other, notice: "Upsell was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def checkout
    @upsell = Upsell.find(params[:id])
    session = create_checkout_session(@upsell)

    # Save the Checkout Session ID in the Upsell record
    @upsell.update(stripe_checkout_session_id: session.id)

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    flash[:error] = "Payment error: #{e.message}"
    redirect_to upsell_path(@upsell)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_upsell
      @upsell = Upsell.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def upsell_params
      params.expect(upsell: [ :title, :description, :price ])
    end
end
