class Approval < ActiveRecord::Base
  belongs_to :approvable, :polymorphic => true
  belongs_to :user
end

