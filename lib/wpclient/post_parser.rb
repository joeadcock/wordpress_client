module Wpclient
  class PostParser
    def self.parse(data)
      new(data).to_post
    end

    def initialize(data)
      @data = data
    end

    def to_post
      meta, meta_ids = parse_metadata

      Post.new(
        id: id,
        url: url,
        title: title,
        guid: guid,
        excerpt_html: excerpt_html,
        content_html: content_html,
        updated_at: updated_at,
        date: date,
        categories: parse_categories,
        meta: meta,
        meta_ids: meta_ids
      )
    end

    private
    attr_reader :data

    def id
      data["id"]
    end

    def url
      data["link"]
    end

    def title
      rendered("title")
    end

    def guid
      rendered("guid")
    end

    def excerpt_html
      rendered("excerpt")
    end

    def content_html
      rendered("content")
    end

    def updated_at
      read_date("modified")
    end

    def date
      read_date("date")
    end

    def parse_categories
      embedded_terms("category").map do |category|
        Category.parse(category)
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
      embedded_metadata = datap["_embedded"].fetch("http://v2.wp-api.org/meta", []).flatten
      validate_embedded_metadata(embedded_metadata)

      meta = {}
      meta_ids = {}

      embedded_metadata.flatten.each do |entry|
        meta[entry.fetch("key")] = entry.fetch("value")
        meta_ids[entry.fetch("key")] = entry.fetch("id")
      end

      [meta, meta_ids]
    end

    def embedded_terms(type)
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
