module WordpressClient
  # @private
  class PostParser
    include RestParser

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
      assign_dates(post)
      assign_rendered(post)
      assign_categories(post)
      assign_tags(post)
      assign_featured_image(post)

      post
    end

    private
    attr_reader :data, :embedded

    def assign_basic(post)
      post.id = data["id"]
      post.slug = data["slug"]
      post.url = data["link"]
      post.status = data["status"]
    end

    def assign_dates(post)
      post.updated_at = read_date("modified")
      post.date = read_date("date")
    end

    def assign_rendered(post)
      post.guid = rendered("guid")
      post.title_html = rendered("title")
      post.excerpt_html = rendered("excerpt")
      post.content_html = rendered("content")
    end

    def assign_categories(post)
      post.categories = embedded_terms("https://api.w.org/term", "category").map do |category|
        Category.parse(category)
      end
    end

    def assign_tags(post)
      post.tags = embedded_terms("wp:term", "post_tag").map do |tag|
        Tag.parse(tag)
      end
    end

    def assign_featured_image(post)
      featured_id = data["featured_image"]
      if featured_id
        features = (embedded["https://api.w.org/featuredmedia"] || []).flatten
        media = features.detect { |feature| feature["id"] == featured_id }
        if media
          post.featured_image = Media.parse(media)
        end
      end
    end

    def parse_metadata
      embedded_metadata = (embedded["https://api.w.org/meta"] || []).flatten
      validate_embedded_metadata(embedded_metadata)

      meta = {}
      meta_ids = {}

      embedded_metadata.each do |entry|
        meta[entry.fetch("key")] = entry.fetch("value")
        meta_ids[entry.fetch("key")] = entry.fetch("id")
      end

      [meta, meta_ids]
    end

    def embedded_terms(term, type)
      term_collections = embedded[term] || []

      # term_collections is an array of arrays with terms in them. We can see
      # the type of the "collection" by inspecting the first child's taxonomy.
      term_collections.detect { |terms|
        terms.size > 0 && terms.is_a?(Array) && terms.first["taxonomy"] == type
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
