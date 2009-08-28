class Item < ActiveRecord::Base
  belongs_to :node
  belongs_to :request, :touch => true, :autosave => true
  has_many :versions, :autosave => true do
    def for_perspective( perspective )
      self.each do |v|
        return v if v.perspective == perspective
      end
      nil
    end
    def perspectives
      self.map { |v| v.perspective }
    end
    def next(attributes = {})
      if last then
        return last if last.new_record?
        return nil if last.perspective == Version::PERSPECTIVES.last
        perspective = Version::PERSPECTIVES[ Version::PERSPECTIVES.index(last.perspective) + 1 ]
      end
      perspective ||= Version::PERSPECTIVES.first
      version = build
      version.build_requestable
      version.attributes = attributes.merge( { :perspective => perspective } )
      version
    end
    def existing
      self.reject { |version| version.new_record? }
    end
  end
  acts_as_tree

  accepts_nested_attributes_for :versions

  validates_presence_of :node
  validates_presence_of :request
  validate_on_create :node_must_be_allowed
  validate_on_update :node_must_not_change

  def allowed_nodes
    Node.allowed_for_children_of( request, parent )
  end

  def node_must_be_allowed
    return if node.nil?
    errors.add( :node_id, "must be an allowed node." ) unless allowed_nodes.include?( node )
  end

  def node_must_not_change
    errors.add( :node_id, "must not change." ) if node_id_changed?
  end

  def may_create?(user)
    request.may_update?(user)
  end

  def may_update?(user)
    request.may_update?(user)
  end

  def may_destroy?(user)
    request.may_update?(user)
  end

  def may_see?(user)
    request.may_see?(user)
  end

  def to_s
    "#{node} item of #{request}"
  end
end

