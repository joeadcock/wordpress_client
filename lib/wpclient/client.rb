require "faraday"
require "json"

module Wpclient
  class Client
    attr_reader :url, :username

    def initialize(url:, username:, password:)
      @connection = Connection.new(url: url, username: username, password: password)
      @url = url
      @username = username
      @password = password
    end

    def posts(per_page: 10, page: 1)
      connection.get_multiple(Post, "posts", per_page: per_page, page: page, _embed: nil)
    end

    def find_post(id)
      connection.get(Post, "posts/#{id.to_i}", _embed: nil)
    end

    def find_by_slug(slug)
      posts = connection.get_multiple(Post, "posts", per_page: 1, filter: {name: slug}, _embed: nil)
      if posts.size > 0
        posts.first
      else
        raise NotFoundError, "Could not find post with slug #{slug.to_s.inspect}"
      end
    end

    def categories(per_page: 10, page: 1)
      connection.get_multiple(Category, "terms/category", page: page, per_page: per_page)
    end

    def find_category(id)
      connection.get(Category, "terms/category/#{id.to_i}")
    end

    def create_post(attributes)
      post = connection.create(Post, "posts", attributes, redirect_params: {_embed: nil})

      assign_meta(post, attributes[:meta])
      assign_categories(post, attributes[:category_ids])

      find_post(post.id)
    end

    def create_category(attributes)
      connection.create(Category, "terms/category", attributes)
    end

    def update_post(id, attributes)
      post = connection.patch(Post, "posts/#{id.to_i}?_embed", attributes)

      assign_meta(post, attributes[:meta])
      assign_categories(post, attributes[:category_ids])

      if attributes.has_key?(:meta) || attributes.has_key?(:category_ids)
        find_post(post.id)
      else
        post
      end
    end

    def update_category(id, attributes)
      connection.patch(Category, "terms/category/#{id.to_i}", attributes)
    end

    def assign_category_to_post(post_id:, category_id:)
      connection.create_without_response("posts/#{post_id}/terms/category/#{category_id}", {})
    end

    def remove_category_from_post(post_id:, category_id:)
      connection.delete("posts/#{post_id}/terms/category/#{category_id}", force: true)
    end

    def assign_meta_to_post(post_id:, key:, value:)
      connection.create_without_response("posts/#{post_id}/meta", key: key, value: value)
    end

    def remove_meta_from_post(post_id:, meta_id:)
      connection.delete("posts/#{post_id}/meta/#{meta_id}", force: true)
    end

    def update_meta_on_post(post_id:, meta_id:, key:, value:)
      connection.patch_without_response("posts/#{post_id}/meta/#{meta_id}", key: key, value: value)
    end

    def inspect
      "#<Wpclient::Client #{connection.inspect}>"
    end

    private
    attr_reader :connection

    def assign_categories(post, category_ids)
      ReplaceCategories.call(self, post, category_ids) if category_ids
    end

    def assign_meta(post, meta)
      ReplaceMetadata.call(self, post, meta) if meta
    end
  end
end
