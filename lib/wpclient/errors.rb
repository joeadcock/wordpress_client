module Wpclient
  Error = Class.new(::StandardError)
  TimeoutError = Class.new(Error)
  ServerError = Class.new(Error)
end
