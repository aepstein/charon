class RequestBasis < ActiveRecord::Base
  belongs_to :request_structure
  has_many :requests

  validates_presence_of :request_structure
end

