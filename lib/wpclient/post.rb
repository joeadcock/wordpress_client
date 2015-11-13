require "time"

module Wpclient
  class Post
    attr_reader(
      :id, :title, :url, :guid,
      :excerpt_html, :content_html,
      :updated_at, :date,
      :categories, :meta
    )

    def self.parse(data)
      PostParser.parse(data)
    end

    def initialize(
      id:,
      url:,
      title:,
      guid:,
      excerpt_html:,
      content_html:,
      updated_at:,
      date:,
      categories: [],
      meta: {},
      meta_ids: {}
    )
      @id = id
      @url = url
      @title = title
      @guid = guid
      @excerpt_html = excerpt_html
      @content_html = content_html
      @updated_at = updated_at
      @date = date
      @categories = categories
      @meta = meta
      @meta_ids = meta_ids
    end

    def category_ids() categories.map(&:id) end

    def meta_id_for(key)
      @meta_ids[key] || raise(ArgumentError, "Post does not have meta #{key.inspect}")
    end
  end
end
