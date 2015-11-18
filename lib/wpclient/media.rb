module Wpclient
  class Media
    attr_accessor(
      :id, :slug, :title, :description,
      :date, :updated_at,
      :guid, :link, :media_details
    )

    def self.parse(data)
      MediaParser.parse(data)
    end

    def initialize(
      id: nil,
      slug: nil,
      title: nil,
      description: nil,
      date: nil,
      updated_at: nil,
      guid: nil,
      link: nil,
      media_details: {}
    )
      @id = id
      @slug = slug
      @title = title
      @date = date
      @updated_at = updated_at
      @description = description
      @guid = guid
      @link = link
      @media_details = media_details
    end
  end
end
