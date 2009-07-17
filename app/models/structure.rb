class Structure < ActiveRecord::Base
  KINDS = %w( safc gpsafc )

  has_many :nodes do
    def children_of(node)
      self.select { |n| n.parent_id == node.id }
    end
    def root
      self.select { |n| n.parent_id.nil? }
    end
  end
  has_many :bases
  has_many :requests

  validates_inclusion_of :kind, :in => KINDS
  validates_numericality_of :minimum_requestors, :only_integer => true
  validates_numericality_of :maximum_requestors, :only_integer => true

  validate :minimum_may_not_exceed_maximum_requestors

  def minimum_may_not_exceed_maximum_requestors
    errors.add( :minimum_requestors,
                "may not exceed maximum requestors." ) if minimum_requestors > maximum_requestors
  end

  def eligible_to_request?(organization)
    organization.send("#{kind}_eligible?")
  end

  def to_s
    name
  end
end

