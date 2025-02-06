class Task < ApplicationRecord
  belongs_to :checklist

  validates :name, presence: true
end
