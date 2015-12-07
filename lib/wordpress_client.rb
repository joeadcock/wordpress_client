require "wordpress_client/version"
require "wordpress_client/errors"

require "wordpress_client/rest_parser"
require "wordpress_client/connection"
require "wordpress_client/client"
require "wordpress_client/paginated_collection"

require "wordpress_client/term"
require "wordpress_client/category"
require "wordpress_client/tag"

require "wordpress_client/post"
require "wordpress_client/post_parser"
require "wordpress_client/media"
require "wordpress_client/media_parser"

require "wordpress_client/replace_terms"
require "wordpress_client/replace_metadata"

module WordpressClient
  def self.new(*args)
    Client.new(Connection.new(*args))
  end
end
