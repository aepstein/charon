class Structure < ActiveRecord::Base
  default_scope :order => 'structures.name ASC'

  has_many :nodes, :include => [ :parent ] do
    def children_of(node)
      self.select { |n| n.parent == node }
    end
    def root
      self.select { |n| n.parent.nil? }
    end
    def allowed_under( node )
      self.select { |n| n.parent == node }
    end
  end
  has_many :bases
  has_many :requests

  validates_numericality_of :minimum_requestors, :only_integer => true
  validates_numericality_of :maximum_requestors, :only_integer => true

  validate :minimum_may_not_exceed_maximum_requestors

  include GlobalModelAuthorization

  def minimum_may_not_exceed_maximum_requestors
    errors.add( :minimum_requestors,
                "may not exceed maximum requestors." ) if minimum_requestors > maximum_requestors
  end

  def to_s
    name
  end
end

