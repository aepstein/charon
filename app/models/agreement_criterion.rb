class AgreementCriterion < ActiveRecord::Base
  belongs_to :agreement
  has_many :fullfillments, :as => :fulfilled, :dependent => :delete_all

  validates_presence_of :agreement
  validates_uniqueness_of :agreement_id

  after_create do |criterion|
    # TODO
    # Mark all users who have signed this agreement as passing criterion
  end

  after_update do |criterion|
    # TODO
    # Unfulfill all users who have not approved the new agreement
    # Fulfill all users who have approved the new agreement but do not have fulfillments
  end
end

