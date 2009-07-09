class Approval < ActiveRecord::Base
  belongs_to :request
  belongs_to :user

  def to_s
    "Approval of #{user} for #{request}"
  end
end

