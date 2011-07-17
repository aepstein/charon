module FulfillableCollection
  def fulfillable_identifiers
    map { |item| [ item.fulfillable_id, item.fulfillable_type ] }
  end
end

