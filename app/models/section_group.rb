# app/models/section_group.rb
class SectionGroup < ApplicationRecord
  belongs_to :section
  belongs_to :group
  has_many :tasks, -> { order(position: :asc) }, dependent: :destroy
  
  validates :group_id, uniqueness: { scope: :section_id }
  
  before_create :set_position
 
  private
  
  def set_position
    self.position = section.section_groups.maximum(:position).to_i + 1
  end
end

