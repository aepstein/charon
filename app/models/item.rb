class Item < ActiveRecord::Base
  default_scope :order => 'items.position ASC'

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
        attributes = last.attributes.merge( attributes )
        previous_requestable_attributes = last.requestable.attributes if last.requestable
      end
      perspective ||= Version::PERSPECTIVES.first
      previous_attributes ||= Hash.new
      previous_requestable_attributes ||= Hash.new
      version = build
      version.build_requestable( previous_requestable_attributes )
      version.attributes = attributes.merge( { :perspective => perspective } )
      version
    end
    def existing
      self.reject { |version| version.new_record? }
    end
  end
  acts_as_list :scope => :parent_id
  acts_as_tree

  accepts_nested_attributes_for :versions

  delegate :requestors, :to => :request

  validates_presence_of :title
  validates_presence_of :node
  validates_presence_of :request
  validates_numericality_of :amount, :greater_than_or_equal_to => 0.0
  validate_on_create :node_must_be_allowed
  validate_on_update :node_must_not_change

  before_validation_on_create :set_title

  def initialize_next_version
    children.each { |item| item.initialize_next_version }
    versions.next
  end

  def set_title
    self.title = node.name if title.nil? || title.blank?
  end

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
    title
  end
end

