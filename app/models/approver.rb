class Approver < ActiveRecord::Base
  belongs_to :framework
  belongs_to :role

  validates_presence_of :framework
  validates_presence_of :role
  validates_inclusion_of :status, :in => Request.aasm_state_names
  validates_inclusion_of :perspective, :in => Version::PERSPECTIVES
  validates_uniqueness_of :role_id, :scope => [ :framework_id, :status, :perspective ]

  default_scope :include => [:role], :order => 'status ASC, perspective ASC, roles.name ASC'
  named_scope :status, lambda { |status| { :conditions => { :status => status } } }

  delegate :may_update?, :to => :framework
  delegate :may_see?, :to => :framework

  def may_create?(user)
    may_update? user
  end

  def may_destroy?(user)
    may_update? user
  end
end

