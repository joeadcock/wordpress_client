require "spec_helper"

describe "Posts with attachments" do
  setup_integration_client

  it "exposes featured image as a Media instance" do
    media = find_or_upload_media
    post = client.create_post(title: "With media", featured_image: media.id)

    expect(post.featured_image).to be_instance_of(WordpressClient::Media)
    expect(post.featured_image.slug).to eq media.slug
    expect(post.featured_image.guid).to eq media.guid
    expect(post.featured_image.source_url).to eq media.source_url
    expect(post.featured_image_id).to eq media.id
  end

  def find_or_upload_media
    client.media(per_page: 1).first ||
      client.upload_file(fixture_path("thoughtful.jpg"), mime_type: "image/jpeg")
  end
end
