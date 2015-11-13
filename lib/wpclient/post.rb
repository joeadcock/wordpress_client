require "time"

module Wpclient
  class Post
    attr_reader(
      :id, :title, :url, :guid,
      :excerpt_html, :content_html,
      :updated_at, :date,
      :categories, :meta
    )

    # TODO: Expand and replace the normal "new" method
    def self.parse(*args) new(*args) end

    def initialize(data)
      @id = data["id"]
      @url = data["link"]

      @title = rendered(data, "title")
      @guid = rendered(data, "guid")
      @excerpt_html = rendered(data, "excerpt")
      @content_html = rendered(data, "content")

      @updated_at = read_date(data, "modified")
      @date = read_date(data, "date")

      @categories = read_categories(data)

      @meta = {}
      @meta_ids = {}
      read_and_assign_metadata(data["_embedded"])
    end

    def category_ids() categories.map(&:id) end

    def meta_id_for(key)
      @meta_ids[key] || raise(ArgumentError, "Post does not have meta #{key.inspect}")
    end

    private
    def rendered(data, name)
      (data[name] || {})["rendered"]
    end

    def read_date(data, name)
      # Try to read UTC time first
      if (gmt_time = data["#{name}_gmt"])
        Time.iso8601("#{gmt_time}Z")
      elsif (local_time = data[name])
        Time.iso8601(local_time)
      end
    end

    def read_categories(data)
      embedded_terms(data, "category").map do |category|
        Category.parse(category)
      end
    end

    def read_and_assign_metadata(embeds)
      embedded_metadata = embeds.fetch("http://v2.wp-api.org/meta", []).flatten
      validate_embedded_metadata(embedded_metadata)

      embedded_metadata.flatten.each do |entry|
        @meta[entry.fetch("key")] = entry.fetch("value")
        @meta_ids[entry.fetch("key")] = entry.fetch("id")
      end
    end

    def embedded_terms(data, type)
      term_collections = data.fetch("_embedded", {})["http://v2.wp-api.org/term"] || []

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
