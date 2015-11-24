require "time"

module Wpclient
  class Post
    attr_accessor(
      :id, :slug, :url, :guid, :status,
      :title_html, :excerpt_html, :content_html,
      :updated_at, :date,
      :categories, :tags, :meta, :featured_image
    )

    def self.parse(data)
      PostParser.parse(data)
    end

    def initialize(
      id: nil,
      url: nil,
      guid: nil,
      status: "unknown",
      title_html: nil,
      excerpt_html: nil,
      content_html: nil,
      updated_at: nil,
      date: nil,
      categories: [],
      tags: [],
      featured_image: nil,
      meta: {},
      meta_ids: {}
    )
      @id = id
      @url = url
      @guid = guid
      @status = status
      @title_html = title_html
      @excerpt_html = excerpt_html
      @content_html = content_html
      @updated_at = updated_at
      @date = date
      @categories = categories
      @tags = tags
      @featured_image = featured_image
      @meta = meta
      @meta_ids = meta_ids
    end

    def category_ids() categories.map(&:id) end

    def tag_ids() tags.map(&:id) end

    def featured_image_id
      featured_image && featured_image.id
    end

    def meta_id_for(key)
      @meta_ids[key] || raise(ArgumentError, "Post does not have meta #{key.inspect}")
    end
  end
end
