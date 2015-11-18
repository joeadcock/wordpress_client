require "wpclient/version"
require "wpclient/errors"

require "wpclient/connection"
require "wpclient/client"
require "wpclient/paginated_collection"

require "wpclient/term"
require "wpclient/category"
require "wpclient/tag"

require "wpclient/post"
require "wpclient/post_parser"
require "wpclient/media"
require "wpclient/media_parser"

require "wpclient/replace_terms"
require "wpclient/replace_metadata"

module Wpclient
  def self.new(*args)
    Client.new(Connection.new(*args))
  end
end
