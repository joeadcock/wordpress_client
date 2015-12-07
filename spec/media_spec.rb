require "spec_helper"

module WordpressClient
  describe Media do
    let(:fixture) { json_fixture("image-media.json") }

    it "can be parsed from JSON data" do
      media = Media.parse(fixture)

      expect(media.id).to eq 5
      expect(media.title_html).to eq "thoughtful"
      expect(media.slug).to eq "thoughtful"
      expect(media.description).to eq ""

      expect(media.guid).to eq "http://example.com/wp-content/uploads/2015/11/thoughtful.jpg"
      expect(media.source_url).to eq "http://example.com/wp-content/uploads/2015/11/thoughtful.jpg"
      expect(media.link).to eq "http://example.com/?attachment_id=5"

      expect(media.date).to_not be_nil
      expect(media.updated_at).to_not be_nil
    end

    it "exposes media information" do
      expect(Media.parse(fixture).media_details).to eq fixture.fetch("media_details")
    end

    it "tries to read guid from source_url if guid is not present" do
      # This happens for associated attachments of posts, for example.
      fixture.delete("guid")
      fixture["source_url"] = "http://example.com/image.jpg"

      media = Media.parse(fixture)
      expect(media.guid).to eq "http://example.com/image.jpg"
      expect(media.source_url).to eq "http://example.com/image.jpg"
    end

    describe "dates" do
      it "uses GMT times if available" do
        media = Media.parse(fixture.merge(
          "date_gmt" => "2001-01-01T15:00:00",
          "date" => "2001-01-01T12:00:00",
          "modified_gmt" => "2001-01-01T15:00:00",
          "modified" => "2001-01-01T12:00:00",
        ))

        expect(media.date).to eq Time.utc(2001, 1, 1, 15, 0, 0)
        expect(media.updated_at).to eq Time.utc(2001, 1, 1, 15, 0, 0)
      end

      it "falls back to local time if no GMT date is provided" do
        media = Media.parse(fixture.merge(
          "date_gmt" => nil,
          "date" => "2001-01-01T12:00:00",
          "modified_gmt" => nil,
          "modified" => "2001-01-01T12:00:00",
        ))

        expect(media.date).to eq Time.local(2001, 1, 1, 12, 0, 0)
        expect(media.updated_at).to eq Time.local(2001, 1, 1, 12, 0, 0)
      end
    end
  end
end
