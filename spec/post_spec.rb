require "spec_helper"

describe Wpclient::Post do
  let(:fixture) { json_fixture("simple-post.json") }

  it "can be parsed from JSON data" do
    post = Wpclient::Post.new(fixture)

    expect(post.id).to eq 1
    expect(post.title).to eq "Hello world!"

    expect(post.url).to eq "http://example.com/2015/11/03/hello-world/"
    expect(post.guid).to eq "http://example.com/?p=1"

    expect(post.excerpt_html).to eq(
      "<p>Welcome to WordPress. This is your first post. Edit or delete it, then start " \
      "writing!</p>\n"
    )

    expect(post.content_html).to eq(
      "<p>Welcome to WordPress. This is your first post. Edit or delete it, then start " \
      "writing!</p>\n"
    )

    expect(post.date).to_not be nil
    expect(post.updated_at).to_not be nil
  end

  it "parses categories" do
    post = Wpclient::Post.new(fixture)

    expect(post.categories).to eq [
      Wpclient::Category.new(
        id: 1, name: "Uncategorized", slug: "uncategorized"
      )
    ]

    expect(post.category_ids).to eq [1]
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

  describe "metadata" do
    it "is parsed into a hash" do
      post = Wpclient::Post.new(json_fixture("post-with-metadata.json"))
      expect(post.meta).to eq "foo" => "bar"
    end

    it "raises UnauthorizedError when post it is forbidden" do
      expect {
        Wpclient::Post.new(json_fixture("post-with-forbidden-metadata.json"))
      }.to raise_error(Wpclient::UnauthorizedError)
    end
  end
end
