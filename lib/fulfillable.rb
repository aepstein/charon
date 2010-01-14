module Fulfillable
  def fulfiller_type; Fulfillment.fulfiller_type_for_fulfillable self.class.to_s; end
end

