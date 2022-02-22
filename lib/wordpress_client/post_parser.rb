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
      post = Post.new
      assign_basic(post)
      assign_dates(post)
      assign_rendered(post)
      assign_categories(post)
      assign_tags(post)
      assign_featured_media(post)
      post
    end

    private
    attr_reader :data, :embedded

    def assign_basic(post)
      post.id = data["id"]
      post.slug = data["slug"]
      post.url = data["link"]
      post.status = data["status"]
      post.meta = data["meta"]
      post.category_ids = data["categories"]
      post.tag_ids = data["tags"]
      post.featured_media_id = data["featured_media"]
      post.yoast_head_json = data['yoast_head_json']
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
      post.categories = embedded_terms("category").map do |category|
        Category.parse(category)
      end
    end

    def assign_tags(post)
      post.tags = embedded_terms("post_tag").map do |tag|
        Tag.parse(tag)
      end
    end

    def assign_featured_media(post)
      featured_id = data["featured_media"]
      if featured_id
        features = (embedded["wp:featuredmedia"] || []).flatten
        media = features.detect { |feature| feature["id"] == featured_id }
        if media
          post.featured_media = Media.parse(media)
        end
      end
    end

    def embedded_terms(type)
      term_collections = embedded["wp:term"] || embedded["https://api.w.org/term"] || []

      # term_collections is an array of arrays with terms in them. We can see
      # the type of the "collection" by inspecting the first child's taxonomy.
      term_collections.detect { |terms|
        terms.size > 0 && terms.is_a?(Array) && terms.first["taxonomy"] == type
      } || []
    end

  end
end
