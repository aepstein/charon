module CornellNetId
  VALID_NET_ID = /^\w{2,3}\d{1,4}$/
  class InvalidNetIdError < RuntimeError; end
end