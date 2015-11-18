module Wpclient
  class Client
    def initialize(connection)
      @connection = connection
    end

    def posts(per_page: 10, page: 1, category_slug: nil)
      filter = {}
      filter[:category_name] = category_slug if category_slug
      connection.get_multiple(
        Post, "posts", per_page: per_page, page: page, _embed: nil, filter: filter
      )
    end

    def find_post(id)
      connection.get(Post, "posts/#{id.to_i}", _embed: nil)
    end

    def find_by_slug(slug)
      posts = connection.get_multiple(
        Post, "posts", per_page: 1, page: 1, filter: {name: slug}, _embed: nil
      )
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

    def upload_file(io, mime_type:)
      connection.upload(Media, "media", io, mime_type: mime_type)
    end

    def inspect
      "#<Wpclient::Client #{connection.inspect}>"
    end

    private
    attr_reader :connection

    def assign_categories(post, category_ids)
      ReplaceCategories.call(connection, post, category_ids) if category_ids
    end

    def assign_meta(post, meta)
      ReplaceMetadata.call(connection, post, meta) if meta
    end
  end
end
