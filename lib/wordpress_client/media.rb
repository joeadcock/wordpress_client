module WordpressClient
  class Media
    attr_accessor(
      :id, :slug, :title_html, :description,
      :date, :updated_at,
      :guid, :link, :media_details
    )

    def self.parse(data)
      MediaParser.parse(data)
    end

    def initialize(
      id: nil,
      slug: nil,
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
      @title_html = title_html
      @date = date
      @updated_at = updated_at
      @description = description
      @guid = guid
      @link = link
      @media_details = media_details
    end

    alias source_url guid
  end
end
