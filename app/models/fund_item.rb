class FundItem < ActiveRecord::Base
  #TODO conditionally make amount available based on user role
  attr_accessible :node_id, :parent_id, :new_position, :amount,
    :fund_editions_attributes
  attr_readonly :fund_request_id, :node_id, :parent_id

  belongs_to :node, :inverse_of => :fund_items
  belongs_to :fund_grant, :touch => true, :inverse_of => :fund_items
  has_many :fund_editions, :inverse_of => :fund_item do
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
        return nil if last.perspective == FundEdition::PERSPECTIVES.last
        attributes = last.attributes.merge( attributes )
        attributes['perspective'] = FundEdition::PERSPECTIVES[ FundEdition::PERSPECTIVES.index(last.perspective) + 1 ]
        previous_requestable_attributes = last.requestable.attributes if last.requestable
      end
      attributes['perspective'] ||= FundEdition::PERSPECTIVES.first
      previous_requestable_attributes ||= Hash.new
      fund_edition = build( attributes )
      fund_edition.build_requestable( previous_requestable_attributes )
      fund_edition
    end
    def existing
      self.reject { |fund_edition| fund_edition.new_record? }
    end
  end
  has_many :documents, :through => :fund_editions
  has_many :document_types, :through => :node

  scope :root, where( :parent_id => nil )

  has_paper_trail :class_name => 'SecureVersion'

  acts_as_list :scope => :parent_id
  acts_as_tree

  accepts_nested_attributes_for :fund_editions

  validates :title, :presence => true
  validates :node, :presence => true
  validates :fund_grant, :presence => true
  validates :amount,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validate :node_must_be_allowed, :on => :create

  before_validation :set_title
  after_save :move_to_new_position

  attr_accessor :new_position

  def initialize_next_fund_edition
    children.each { |fund_item| fund_item.initialize_next_fund_edition }
    fund_editions.next
  end

  def set_title
    if fund_editions.first && fund_editions.first.title?
      self.title = fund_editions.first.title
    elsif title.blank? && node
      self.title = node.name
    end
  end

  def allowed_nodes
    Node.allowed_for_children_of( fund_grant, parent ).where( :structure_id => fund_grant.fund_source.structure_id )
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

