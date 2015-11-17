module Wpclient
  class PostParser
    def self.parse(data)
      new(data).to_post
    end

    def initialize(data)
      @data = data
      @embedded = data.fetch("_embedded", {})
    end

    def to_post
      meta, meta_ids = parse_metadata
      post = Post.new(meta: meta, meta_ids: meta_ids)

      assign_basic(post)
      assign_rendered(post)
      assign_categories(post)
      assign_tags(post)

      post
    end

    private
    attr_reader :data, :embedded

    def assign_basic(post)
      post.id = data["id"]
      post.url = data["link"]
      post.updated_at = read_date("modified")
      post.date = read_date("date")
    end

    def assign_rendered(post)
      post.title = rendered("title")
      post.guid = rendered("guid")
      post.excerpt_html = rendered("excerpt")
      post.content_html = rendered("content")
    end

    def assign_categories(post)
      post.categories = embedded_terms("category").map do |category|
        Category.parse(category)
      end
    end

    def assign_tags(post)
      post.tags = embedded_terms("post_tag").map do |tag|
        Tag.parse(tag)
      end
    end

    def rendered(name)
      (data[name] || {})["rendered"]
    end

    def read_date(name)
      # Try to read UTC time first
      if (gmt_time = data["#{name}_gmt"])
        Time.iso8601("#{gmt_time}Z")
      elsif (local_time = data[name])
        Time.iso8601(local_time)
      end
    end

    def parse_metadata
      embedded_metadata = (embedded["http://v2.wp-api.org/meta"] || []).flatten
      validate_embedded_metadata(embedded_metadata)

      meta = {}
      meta_ids = {}

      embedded_metadata.each do |entry|
        meta[entry.fetch("key")] = entry.fetch("value")
        meta_ids[entry.fetch("key")] = entry.fetch("id")
      end

      [meta, meta_ids]
    end

    def embedded_terms(type)
      term_collections = embedded["http://v2.wp-api.org/term"] || []

      # term_collections is an array of arrays with terms in them. We can see
      # the type of the "collection" by inspecting the first child's taxonomy.
      term_collections.detect { |terms|
        terms.size > 0 && terms.first["taxonomy"] == type
      } || []
    end

    def validate_embedded_metadata(embedded_metadata)
      if embedded_metadata.size == 1 && embedded_metadata.first["code"]
        error = embedded_metadata.first
        case error["code"]
        when "rest_forbidden"
          raise UnauthorizedError, error.fetch(
            "message", "You are not authorized to see meta for this post."
          )
        else
          raise Error, "Could not retreive meta for this post: " \
            "#{error["code"]} – #{error["message"]}"
        end
      end
    end
  end
end
