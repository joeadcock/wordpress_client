require "spec_helper"

describe "Posts with attachments" do
  setup_integration_client

  it "exposes featured media as a Media instance" do
    media = find_or_upload_image
    post = client.create_post(title: "With image", featured_media: media.id)
    expect(post.featured_media).to be_instance_of(WordpressClient::Media)
    expect(post.featured_media.id).to eq media.id
    expect(post.featured_media.slug).to eq media.slug
    expect(post.featured_media.guid).to eq media.guid
    expect(post.featured_media.source_url).to eq media.source_url
    expect(post.featured_media_id).to eq media.id
  end

  it "exposes featured media as featured image if Media is an image" do
    media = find_or_upload_image
    post = client.create_post(title: "With image", featured_media: media.id)
    expect(post.featured_image).to be_instance_of(WordpressClient::Media)
    expect(post.featured_image.id).to eq media.id
    expect(post.featured_image.slug).to eq media.slug
    expect(post.featured_image.guid).to eq media.guid
    expect(post.featured_image.source_url).to eq media.source_url
  end

  def find_or_upload_image
    find_media_of_type("image") ||
      client.upload_file(fixture_path("thoughtful.jpg"), mime_type: "image/jpeg")
  end

  def find_media_of_type(type)
    client.media(per_page: 10).detect { |media| media.media_type == type }
  end
end
