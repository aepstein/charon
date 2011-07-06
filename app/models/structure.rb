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
  has_many :fund_sources, :inverse_of => :structure
  has_many :categories, :through => :nodes, :uniq => true

  validates :name, :presence => true, :uniqueness => true

  def to_s; name; end

end

