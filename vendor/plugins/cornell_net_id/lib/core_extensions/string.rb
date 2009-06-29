module CornellNetId::CoreExtensions
  module String
    # Return an array of net_id strings from an input string
    def to_net_ids
      self.split(/[\,\;\\\/\s]+/).inject([]) do |memo, piece|
        candidate = piece[/\A(\w{2,3}\d{1,3})(@cornell\.edu)?\Z/i,1]
        memo << candidate.downcase if candidate
        memo
      end
    end
  
    def to_net_id!
      self.valid_net_id? ? raise(InvalidNetIdError.new) : self
    end
  
    def valid_net_id?
      self.match(VALID_NET_ID) ? true : false
    end
  end
end

class String
  include CornellNetId::CoreExtensions::String
end
