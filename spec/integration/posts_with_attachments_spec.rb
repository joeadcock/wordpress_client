require "spec_helper"

describe "Posts with attachments" do
  setup_integration_client

  it "exposes featured image as a Media instance" do
    media = find_or_upload_media
    post = client.create_post(title: "With media", featured_image: media.id)

    pending
    expect(post.featured_image).to eq media
    expect(post.featured_image_id).to eq media.id
  end

  def find_or_upload_media
    client.media(per_page: 1).first ||
      client.upload_file(fixture_path("thoughtful.jpg"), mime_type: "image/jpeg")
  end
end
