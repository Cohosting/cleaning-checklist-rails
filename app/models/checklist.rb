class Checklist < ApplicationRecord
  belongs_to :property
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  def completed?
    tasks.any? && tasks.all?(&:completed)
  end
end