require "wpclient/version"
require "wpclient/client"

module Wpclient
  def self.new(*args)
    Client.new(*args)
  end
end
