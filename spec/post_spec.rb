require "spec_helper"

describe Wpclient::Post do
  let(:fixture) { json_fixture("simple-post.json") }

  it "can be parsed from JSON data" do
    post = Wpclient::Post.new(fixture)

    expect(post.id).to eq 7
    expect(post.title).to eq "Hello Friend"

    expect(post.url).to eq "https://example.com/2015/11/hello-friend/"
    expect(post.guid).to eq "http://example.com/?p=7"

    expect(post.excerpt_html).to eq "<p>Hello Friend</p>\n"
    expect(post.content_html).to eq "<p>Hello Friend</p>\n"

    expect(post.date).to_not be nil
    expect(post.updated_at).to_not be nil
  end

  describe "dates" do
    it "uses GMT times if available" do
      post = Wpclient::Post.new(fixture.merge(
        "date_gmt" => "2001-01-01T15:00:00",
        "date" => "2001-01-01T12:00:00",
        "modified_gmt" => "2001-01-01T15:00:00",
        "modified" => "2001-01-01T12:00:00",
      ))

      expect(post.date).to eq Time.utc(2001, 1, 1, 15, 0, 0)
      expect(post.updated_at).to eq Time.utc(2001, 1, 1, 15, 0, 0)
    end

    it "falls back to local time if no GMT date is provided" do
      post = Wpclient::Post.new(fixture.merge(
        "date_gmt" => nil,
        "date" => "2001-01-01T12:00:00",
        "modified_gmt" => nil,
        "modified" => "2001-01-01T12:00:00",
      ))

      expect(post.date).to eq Time.local(2001, 1, 1, 12, 0, 0)
      expect(post.updated_at).to eq Time.local(2001, 1, 1, 12, 0, 0)
    end
  end
end
