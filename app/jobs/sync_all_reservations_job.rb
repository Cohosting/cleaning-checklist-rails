class SyncAllReservationsJob < ApplicationJob
  queue_as :default

  def perform
    Property.find_each do |property|
      SyncReservationsJob.perform_later(property.hospitable_id)
    end
  end
end