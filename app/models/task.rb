class Task < ApplicationRecord
  belongs_to :section_group
  has_one :section, through: :section_group
  has_one :group, through: :section_group
  
  validates :content, presence: true
  
  after_initialize :set_defaults, if: :new_record?
  before_create :set_position
 
  private
  
  def set_defaults
    self.completed ||= false
  end
  
  def set_position
    self.position = section_group.tasks.maximum(:position).to_i + 1
  end
end