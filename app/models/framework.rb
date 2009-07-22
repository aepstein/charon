class Framework < ActiveRecord::Base
  has_many :permissions do
    def allowed_actions(roles,context,status)
      self.role(roles).context(context).status(status).map { |p| p.action }.uniq
    end
  end

  validates_presence_of :name
  validates_presence_of :must_register
  validates_inclusion_of :member_percentage_type,
                         :in => Registration::MEMBER_TYPES,
                         :allow_nil => true
  validates_numericality_of :member_percentage, :allow_nil => true,
                            :greater_than => 0, :less_than => 101,
                            :only_integer => true

  before_validation :initialize_member_percentage

  def initialize_member_percentage
    self.member_percentage = nil if member_percentage && member_percentage.empty?
    self.member_percentage_type = nil if member_percentage_type && member_percentage_type.empty?
  end

  def to_s
    name
  end
end

