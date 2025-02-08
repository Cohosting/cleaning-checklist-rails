class Checklist < ApplicationRecord
  belongs_to :property
  has_many :tasks, dependent: :destroy

  after_create :set_as_default_if_first

  private

  def set_as_default_if_first
    if property.default_checklist.nil?
      property.update(default_checklist_id: id)
    end
  end
end