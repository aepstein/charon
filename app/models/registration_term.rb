class RegistrationTerm < ActiveRecord::Base

  named_scope :current, :conditions => { :current => true }

  has_many :registrations, :foreign_key => :external_term_id, :primary_key => :external_id

end

