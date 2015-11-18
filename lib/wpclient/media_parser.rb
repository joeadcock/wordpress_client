module Wpclient
  class MediaParser
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
      media.title = data.fetch("title", {}).fetch("rendered")
      media.guid = data.fetch("guid", {}).fetch("rendered")
    end

    def read_date(name)
      # Try to read UTC time first
      if (gmt_time = data["#{name}_gmt"])
        Time.iso8601("#{gmt_time}Z")
      elsif (local_time = data[name])
        Time.iso8601(local_time)
      end
    end
  end
end
