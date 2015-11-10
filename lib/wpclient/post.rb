require "time"

module Wpclient
  class Post
    attr_reader(
      :id, :title, :url, :guid,
      :excerpt_html, :content_html,
      :updated_at, :date,
      :categories,
    )

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
    end

    def category_ids() categories.map(&:id) end

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

    def embedded_terms(data, type)
      term_collections = data.fetch("_embedded", {})["http://v2.wp-api.org/term"] || []

      # term_collections is an array of arrays with terms in them. We can see
      # the type of the "collection" by inspecting the first child's taxonomy.
      term_collections.find { |terms|
        terms.size > 0 && terms.first["taxonomy"] == type
      } || []
    end
  end
end
