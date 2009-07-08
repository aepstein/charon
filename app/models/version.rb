class Version < ActiveRecord::Base
  belongs_to :item
  belongs_to :stage
  has_one :administrative_expense
  has_one :local_event_expense
  has_one :speaker_expense
  has_one :travel_event_expense
  has_one :durable_goods_expense
  has_one :publication_expense
  accepts_nested_attributes_for :administrative_expense #:requestable

  def validate
    if self.amount > self.requestable.max_request:
      errors.add(:amount, "is greater than the maximum request!")
    end
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

end

