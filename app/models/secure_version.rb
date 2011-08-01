class SecureVersion < Version
  attr_accessible :item_type, :item_id, :event, :whodunnit, :object,
    :created_at
end

