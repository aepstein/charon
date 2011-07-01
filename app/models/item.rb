class Item < ActiveRecord::Base
  #TODO conditionally make amount available based on user role
  attr_accessible :node_id, :parent_id, :new_position, :amount,
    :editions_attributes
  attr_readonly :request_id, :node_id, :parent_id

  belongs_to :node, :inverse_of => :items
  belongs_to :request, :touch => true, :inverse_of => :items
  has_many :editions, :inverse_of => :item do
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
        return nil if last.perspective == Edition::PERSPECTIVES.last
        attributes = last.attributes.merge( attributes )
        attributes['perspective'] = Edition::PERSPECTIVES[ Edition::PERSPECTIVES.index(last.perspective) + 1 ]
        previous_requestable_attributes = last.requestable.attributes if last.requestable
      end
      attributes['perspective'] ||= Edition::PERSPECTIVES.first
      previous_requestable_attributes ||= Hash.new
      edition = build( attributes )
      edition.build_requestable( previous_requestable_attributes )
      edition
    end
    def existing
      self.reject { |edition| edition.new_record? }
    end
  end
  has_many :documents, :through => :editions
  has_many :document_types, :through => :node

  scope :root, where( :parent_id => nil )

  has_paper_trail :class_name => 'SecureVersion'

  acts_as_list :scope => :parent_id
  acts_as_tree

  accepts_nested_attributes_for :editions

  delegate :requestors, :to => :request

  validates :title, :presence => true
  validates :node, :presence => true
  validates :request, :presence => true
  validates :amount,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validate :node_must_be_allowed, :on => :create

  before_validation :set_title
  after_save :move_to_new_position

  attr_accessor :new_position

  def initialize_next_edition
    children.each { |item| item.initialize_next_edition }
    editions.next
  end

  def set_title
    if editions.first && editions.first.title?
      self.title = editions.first.title
    elsif title.blank? && node
      self.title = node.name
    end
  end

  def allowed_nodes
    Node.allowed_for_children_of( request, parent ).where( :structure_id => request.basis.structure_id )
  end

  def node_must_be_allowed
    return if node.nil?
    errors.add( :node_id, "must be an allowed node." ) unless allowed_nodes.include?( node )
  end

  def to_s; title; end

  private

  def move_to_new_position
    unless new_position.blank? || ( (np = new_position.to_i) == position )
      self.new_position = nil
      insert_at np
    end
  end

end

