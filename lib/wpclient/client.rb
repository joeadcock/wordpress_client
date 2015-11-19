module Wpclient
  class Client
    def initialize(connection)
      @connection = connection
    end

    def posts(per_page: 10, page: 1, category_slug: nil, tag_slug: nil)
      filter = {}
      filter[:category_name] = category_slug if category_slug
      filter[:tag] = tag_slug if tag_slug
      connection.get_multiple(
        Post, "posts", per_page: per_page, page: page, _embed: nil, filter: filter
      )
    end

    def categories(per_page: 10, page: 1)
      connection.get_multiple(Category, "terms/category", page: page, per_page: per_page)
    end

    def tags(per_page: 10, page: 1)
      connection.get_multiple(Tag, "terms/tag", page: page, per_page: per_page)
    end

    def media(per_page: 10, page: 1)
      connection.get_multiple(Media, "media", page: page, per_page: per_page)
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

    def find_category(id)
      connection.get(Category, "terms/category/#{id.to_i}")
    end

    def find_tag(id)
      connection.get(Tag, "terms/tag/#{id.to_i}")
    end

    def find_media(id)
      connection.get(Media, "media/#{id.to_i}")
    end

    def create_post(attributes)
      post = connection.create(Post, "posts", attributes, redirect_params: {_embed: nil})

      changes = 0
      changes += assign_meta(post, attributes[:meta])
      changes += assign_categories(post, attributes[:category_ids])
      changes += assign_tags(post, attributes[:tag_ids])

      if changes > 0
        find_post(post.id)
      else
        post
      end
    end

    def create_category(attributes)
      connection.create(Category, "terms/category", attributes)
    end

    def create_tag(attributes)
      connection.create(Tag, "terms/tag", attributes)
    end

    def update_post(id, attributes)
      post = connection.patch(Post, "posts/#{id.to_i}?_embed", attributes)

      changes = 0
      changes += assign_meta(post, attributes[:meta])
      changes += assign_categories(post, attributes[:category_ids])
      changes += assign_tags(post, attributes[:tag_ids])

      if changes > 0
        find_post(post.id)
      else
        post
      end
    end

    def update_category(id, attributes)
      connection.patch(Category, "terms/category/#{id.to_i}", attributes)
    end

    def update_tag(id, attributes)
      connection.patch(Tag, "terms/tag/#{id.to_i}", attributes)
    end

    def update_media(id, attributes)
      connection.patch(Media, "media/#{id.to_i}", attributes)
    end

    def upload(io, mime_type:, filename:)
      connection.upload(Media, "media", io, mime_type: mime_type, filename: filename)
    end

    def upload_file(filename, mime_type:)
      path = filename.to_s
      File.open(path, 'r') do |file|
        upload(file, mime_type: mime_type, filename: File.basename(path))
      end
    end

    def inspect
      "#<Wpclient::Client #{connection.inspect}>"
    end

    private
    attr_reader :connection

    def assign_categories(post, ids)
      return 0 unless ids
      ReplaceTerms.apply_categories(connection, post, ids)
    end

    def assign_tags(post, ids)
      return 0 unless ids
      ReplaceTerms.apply_tags(connection, post, ids)
    end

    def assign_meta(post, meta)
      return 0 unless meta
      ReplaceMetadata.apply(connection, post, meta)
    end
  end
end
