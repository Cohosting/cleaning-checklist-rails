class Organization < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :invitations, dependent: :destroy

  has_many :groups, dependent: :destroy
  has_many :checklists, dependent: :destroy
  has_many :upsells, dependent: :destroy



  has_many :properties, dependent: :destroy

  after_create :create_default_groups
  
  private
  
  def create_default_groups
    default_groups = [
      { name: 'Bathroom', description: 'Bathroom areas', default: true },
      { name: 'Half-Bathroom', description: 'Half-bathroom areas', default: true },
      { name: 'Kitchen', description: 'Kitchen areas', default: true },
      { name: 'Living Room', description: 'Living room areas', default: true },
      { name: 'Hot Tubs', description: 'Hot tub areas', default: true },
      { name: 'Pool', description: 'Pool areas', default: true }
    ]
    
    default_groups.each do |group_attrs|
      groups.create!(group_attrs)
    end
  end
end
