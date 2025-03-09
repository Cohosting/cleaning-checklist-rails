class Section < ApplicationRecord
  belongs_to :checklist
  has_many :section_groups, -> { order(position: :asc) }, dependent: :destroy
  has_many :tasks, through: :section_groups
  
  validates :title, presence: true
  
  before_create :set_position
 
  private
  
  def set_position
    self.position = checklist.sections.maximum(:position).to_i + 1
  end
end
