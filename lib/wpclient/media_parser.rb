module Wpclient
  class MediaParser
    include RestParser

    def self.parse(data)
      new(data).to_media
    end

    def initialize(data)
      @data = data
    end

    def to_media
      media = Media.new

      assign_basic(media)
      assign_dates(media)
      assign_rendered(media)

      media
    end

    private
    attr_reader :data

    def assign_basic(media)
      media.id = data.fetch("id")
      media.slug = data.fetch("slug")
      media.link = data.fetch("link")
      media.description = data.fetch("description")
      media.media_details = data.fetch("media_details")
    end

    def assign_dates(media)
      media.date = read_date("date")
      media.updated_at = read_date("modified")
    end

    def assign_rendered(media)
      media.title = rendered("title")
      media.guid = rendered("guid")
    end
  end
end
