class ReservationsController < ApplicationController
  before_action :set_property
  before_action :set_reservation, only: [ :upsells, :show, :edit]

  def index
    @reservations = @property.reservations
  end

  def show
  end

  def edit
  end

  def new
    @reservation = @property.reservations.build
  end

  def create
 
  end

  def upsells 
    @upsells = @property.upsells

    puts @upsells
  end


  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_reservation
    @reservation = @property.reservations.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:platform, :platform_id, :guest_id, :booking_date, :arrival_date, :departure_date, :nights, :check_in, :check_out, :status, :total_price, :currency)
  end
end
