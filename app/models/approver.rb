class Approver < ActiveRecord::Base
  belongs_to :framework
  belongs_to :role

  validates_presence_of :framework
  validates_presence_of :role
  validates_inclusion_of :status, :in => Request.aasm_state_names
  validates_inclusion_of :perspective, :in => Version::PERSPECTIVES
end

