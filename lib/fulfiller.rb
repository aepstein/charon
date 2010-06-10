module Fulfiller
  def frameworks( perspective ); Framework.fulfilled_for( self, perspective ); end

  def framework_ids( perspective ); self.frameworks( perspective ).map(&:id); end
end

