class Version < ActiveRecord::Base
  belongs_to :item
  belongs_to :requestable, :polymorphic => true, :autosave => true
  belongs_to :stage
  accepts_nested_attributes_for :requestable
end

