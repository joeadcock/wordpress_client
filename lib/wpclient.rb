require "wpclient/version"
require "wpclient/errors"

require "wpclient/client"
require "wpclient/category"
require "wpclient/post"

require "wpclient/replace_categories"
require "wpclient/replace_metadata"

module Wpclient
  def self.new(*args)
    Client.new(*args)
  end
end
