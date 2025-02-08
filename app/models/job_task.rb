class JobTask < ApplicationRecord
  belongs_to :job

  validates :name, presence: true
end
