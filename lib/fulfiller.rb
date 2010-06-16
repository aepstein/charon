module Fulfiller

  def frameworks( perspective, role_ids = nil )
    Framework.fulfilled_for( self, perspective, role_ids )
  end

  def framework_ids( perspective, role_ids = nil )
    self.frameworks( perspective, role_ids ).map(&:id)
  end

end

