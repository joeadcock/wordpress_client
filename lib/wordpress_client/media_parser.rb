module WordpressClient
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
      assign_guid(media)

      media
    end

    private
    attr_reader :data

    def assign_basic(media)
      media.id = data.fetch("id")
      media.slug = data.fetch("slug")
      media.link = data.fetch("link")
      media.description = data["description"]
      media.media_details = data["media_details"]
    end

    def assign_dates(media)
      media.date = read_date("date")
      media.updated_at = read_date("modified")
    end

    def assign_rendered(media)
      media.title_html = rendered("title")
    end

    def assign_guid(media)
      media.guid = rendered("guid") || data["source_url"]
    end
  end
end
