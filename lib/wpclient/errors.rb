module Wpclient
  Error = Class.new(::StandardError)

  TimeoutError = Class.new(Error)
  ServerError = Class.new(Error)
  NotFoundError = Class.new(Error)
  ValidationError = Class.new(Error)
end
