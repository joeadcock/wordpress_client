module WordpressClient
  # Represents a media record in Wordpress.
  class Media
    attr_accessor(
      :id, :slug, :media_type, :title_html, :description,
      :date, :updated_at,
      :guid, :link, :media_details
    )

    # @!attribute [r] media_type
    #   @return [String] the type of the media
    #   @example
    #     media.media_type #=> "image"

    # @!attribute [rw] title_html
    #   @return [String] the title of the media, HTML escaped
    #   @example
    #     media.title_html #=> "Sunset &mdash; Painting by some person"

    # @!attribute [rw] date
    #   @return [Time, nil] the date of the media, in UTC if available

    # @!attribute [rw] updated_at
    #   @return [Time, nil] the modification date of the media, in UTC if available

    # @!attribute [rw] guid
    #   Returns the permalink/GUID – or +source_url+ – of the media.
    #
    #   Media that are embedded in posts have a +source_url+ attribute and no
    #   +guid+, and stand-alone media has a +guid+ but no +source_url+. They
    #   are both backed by the same data, so this method handles both cases,
    #   and is aliased to both names.
    #
    #   @return [String] the permalink/GUID – or +source_url+ – of the media

    # @!attribute [rw] media_details
    #   Returns the media details if available.
    #
    #   Media details cannot be documented here. It's up to you to handle this
    #   generic "payload" attribute the best way you can.
    #
    #   @return [Hash<String,Object>] the media details returned from the server

    # @api private
    def self.parse(data)
      MediaParser.parse(data)
    end

    # Creates a new instance, populating the fields with the passed values.
    def initialize(
      id: nil,
      slug: nil,
      media_type: nil,
      title_html: nil,
      description: nil,
      date: nil,
      updated_at: nil,
      guid: nil,
      link: nil,
      media_details: {}
    )
      @id = id
      @slug = slug
      @media_type = media_type
      @title_html = title_html
      @date = date
      @updated_at = updated_at
      @description = description
      @guid = guid
      @link = link
      @media_details = media_details
    end

    alias source_url guid

    # Returns the same +Media+ instance if it is an image, else +nil+.
    def as_image
      if media_type == "image"
        self
      end
    end
  end
end
