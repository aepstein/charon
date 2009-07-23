class Framework < ActiveRecord::Base
  has_many :permissions do
    def allowed_actions(roles, perspective, status)
      self.role(roles.map { |r| r.id } ).perspective(perspective).status(status).map { |p| p.action }.uniq
    end
  end

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :must_register, :in => [ true, false ]
  validates_inclusion_of :member_percentage_type, :in => Registration::MEMBER_TYPES,
    :if => :member_percentage?,
    :message => 'can\'t be blank if member percentage is specified.'
  validates_numericality_of :member_percentage, :greater_than => 0,
    :less_than => 101, :only_integer => true, :if => :member_percentage_type?,
    :message => 'must be an integer percentage if member percentage type is also specified.'

  before_validation :initialize_member_percentage

  def initialize_member_percentage
    self.member_percentage_type = nil if member_percentage_type && member_percentage_type.empty?
  end

  def to_s
    name
  end
end

