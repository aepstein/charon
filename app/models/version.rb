class Version < ActiveRecord::Base
  STAGE_NAMES = %w( request review )
  belongs_to :item
  has_one :administrative_expense
  has_one :local_event_expense
  has_one :speaker_expense
  has_one :travel_event_expense
  has_one :durable_goods_expense
  has_one :publication_expense
  accepts_nested_attributes_for :administrative_expense
  accepts_nested_attributes_for :local_event_expense
  accepts_nested_attributes_for :speaker_expense
  accepts_nested_attributes_for :travel_event_expense
  accepts_nested_attributes_for :durable_goods_expense
  accepts_nested_attributes_for :publication_expense

  delegate :request, :to => :item

  def validate
    if amount > requestable.max_request:
      errors.add(:amount, "is greater than the maximum request!")
    end
  end

  def stage
    STAGE_NAMES[stage_id]
  end

  def requestable
    self.send("#{item.node.requestable_type.underscore}")
  end
  def build_requestable
    self.send("build_#{item.node.requestable_type.underscore}")
  end
  def create_requestable
    self.send("create_#{item.node.requestable_type.underscore}")
  end
  def requestable=(requestable)
    self.send("#{item.node.requestable_type.underscore}=",requestable)
  end

  def may_create?(user)
    return request.may_allocate?(user) if stage_id == 1
    false
  end

  def may_update?(user)
    return request.may_allocate?(user) if stage_id == 1
    request.may_update?(user)
  end

  def may_destroy?(user)
    false
  end

  def may_see?(user)
    if stage_id == 1
      return request.may_allocate?(user) || request.may_review?(user)
    end
    request.may_see?(user)
  end
end

