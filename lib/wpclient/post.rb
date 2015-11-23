require "time"

module Wpclient
  class Post
    attr_accessor(
      :id, :title, :slug, :url, :guid, :status,
      :excerpt_html, :content_html,
      :updated_at, :date,
      :categories, :tags, :meta
    )

    def self.parse(data)
      PostParser.parse(data)
    end

    def initialize(
      id: nil,
      url: nil,
      title: nil,
      guid: nil,
      status: "unknown",
      excerpt_html: nil,
      content_html: nil,
      updated_at: nil,
      date: nil,
      categories: [],
      tags: [],
      meta: {},
      meta_ids: {}
    )
      @id = id
      @url = url
      @title = title
      @guid = guid
      @status = status
      @excerpt_html = excerpt_html
      @content_html = content_html
      @updated_at = updated_at
      @date = date
      @categories = categories
      @tags = tags
      @meta = meta
      @meta_ids = meta_ids
    end

    def category_ids() categories.map(&:id) end

    def tag_ids() tags.map(&:id) end

    def meta_id_for(key)
      @meta_ids[key] || raise(ArgumentError, "Post does not have meta #{key.inspect}")
    end
  end
end
