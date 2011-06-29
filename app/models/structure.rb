class Structure < ActiveRecord::Base
  attr_accessible :name

  default_scope order( 'structures.name ASC' )

  has_many :nodes, :include => [ :parent ], :inverse_of => :structure do
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
  has_many :bases, :inverse_of => :structure
  has_many :categories, :through => :nodes, :uniq => true

  validates_numericality_of :minimum_requestors, :only_integer => true
  validates_numericality_of :maximum_requestors, :only_integer => true

  validate :minimum_may_not_exceed_maximum_requestors

  def minimum_may_not_exceed_maximum_requestors
    errors.add( :minimum_requestors,
                "may not exceed maximum requestors." ) if minimum_requestors > maximum_requestors
  end

  def to_s; name; end

end

