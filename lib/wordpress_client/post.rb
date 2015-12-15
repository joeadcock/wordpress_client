require "time"

module WordpressClient
  # Represents a post in Wordpress.
  #
  # @see http://v2.wp-api.org/reference/posts/ API documentation for Post
  class Post
    attr_accessor(
      :id, :slug, :url, :guid, :status,
      :title_html, :excerpt_html, :content_html,
      :updated_at, :date,
      :categories, :tags, :meta, :featured_image
    )

    # @!attribute [rw] title_html
    #   @return [String] the title of the media, HTML escaped
    #   @example
    #     post.title_html #=> "Fire &amp; diamonds!"

    # @!attribute [rw] date
    #   @return [Time, nil] the date of the post, in UTC if available

    # @!attribute [rw] updated_at
    #   @return [Time, nil] the modification date of the post, in UTC if available

    # @!attribute [rw] guid
    #   @return [String] the permalink/GUID of the post for internal addressing
    #   @see #url

    # @!attribute [rw] url
    #   @return [String] the URL (link) to the post

    # @!attribute [rw] status
    #   @return ["publish", "future", "draft", "pending", "private", nil] the
    #           current status of the post, or +nil+ if undetermined

    # @!attribute [rw] categories
    #   @return [Array[Category]] the {Category Categories} the post belongs to.
    #   @see Category

    # @!attribute [rw] tags
    #   @return [Array[Tag]] the {Tag Tags} the post belongs to.
    #   @see Tag

    # @!attribute [rw] featured_image
    #   @return [Media, nil] the featured image, as an instance of {Media}
    #   @see Media

    # @!attribute [rw] meta
    #   Returns the Post meta, as a +Hash+ of +String => String+.
    #
    #   @example
    #     post.meta # => {"Mood" => "Happy", "reviewed_by" => "user:45"}
    #
    #   @return [Hash<String,String>] the post meta, as a Hash.
    #   @see Category
    #   @see Client#update_post

    # @!attribute [rw] meta_ids
    #   @api private
    #   Backs the {#meta_id_for} method. Used when constructing requests.

    # @api private
    def self.parse(data)
      PostParser.parse(data)
    end

    # Construct a new instance with the given attributes.
    def initialize(
      id: nil,
      slug: nil,
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
      @slug = slug
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

    # A list of all category ids for the post.
    #
    # You can pass this list, with IDs added or removed, to
    # {Client#update_post} to change the category list.
    #
    # @return [Array[Fixnum]] the id of every category associated with this post
    # @see Client#update_post
    def category_ids() categories.map(&:id) end

    # A list of all tag ids for the post.
    #
    # You can pass this list, with IDs added or removed, to
    # {Client#update_post} to change the tag list.
    #
    # @return [Array[Fixnum]] the id of every tag associated with this post
    # @see Client#update_post
    def tag_ids() tags.map(&:id) end

    # @return [Fixnum, nil] ID of the featured image associated with the post.
    def featured_image_id
      featured_image && featured_image.id
    end

    # @api private
    # Used to determine the underlying ID of the different meta keys so they
    # can be modified by {Client}. You should not use this for anything.
    def meta_id_for(key)
      @meta_ids[key] || raise(ArgumentError, "Post does not have meta #{key.inspect}")
    end
  end
end
