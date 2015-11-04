require "time"

module Wpclient
  class Post
    attr_reader(
      :id, :title, :url, :guid,
      :excerpt_html, :content_html,
      :updated_at, :date,
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
  end
end
