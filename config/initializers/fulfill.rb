ActiveSupport.on_load(:active_record) do
  include Fulfiller
  include Fulfillable
end

