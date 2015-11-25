require "spec_helper"

describe "Attachments" do
  setup_integration_client

  it "can be created" do
    media = open_fixture("thoughtful.jpg") do |io|
      client.upload(io, mime_type: "image/jpeg", filename: "thoughtful.jpg")
    end

    expect(media).to be_instance_of(Wpclient::Media)

    expect(client.find_media(media.id)).to be_instance_of(Wpclient::Media)
  end

  it "can be created from a file on disk" do
    path = fixture_path("thoughtful.jpg")
    media = client.upload_file(path, mime_type: "image/jpeg")

    expect(media).to be_instance_of(Wpclient::Media)

    expect(client.find_media(media.id)).to be_instance_of(Wpclient::Media)
  end

  it "can be updated" do
    media = find_or_create_attachment
    updated = client.update_media(media.id, title: "Totally updated media")
    expect(updated.title_html).to eq "Totally updated media"
  end

  it "can be listed" do
    find_or_create_attachment

    media = client.media(per_page: 1)

    expect(media.size).to be > 0
    expect(media.first).to be_instance_of(Wpclient::Media)
  end

  it "uses HTML for the title" do
    media = find_or_create_attachment
    updated = client.update_media(media.id, title: "Images & paint")
    expect(updated.title_html).to eq "Images &amp; paint"
  end

  def find_or_create_attachment
    client.media(per_page: 1).first || open_fixture("thoughtful.jpg") do |io|
      client.upload(io, mime_type: "image/jpeg", filename: "thoughtful.jpg")
    end
  end
end
