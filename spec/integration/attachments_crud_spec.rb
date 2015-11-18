require "spec_helper"

describe "Attachments" do
  setup_integration_client

  it "can be created" do
    media = open_fixture("thoughtful.jpg") do |file|
      client.upload_file(file, mime_type: "image/jpeg", filename: "thoughtful.jpg")
    end

    expect(media).to be_instance_of(Wpclient::Media)

    expect(client.find_media(media.id)).to be_instance_of(Wpclient::Media)
  end

  it "can be updated" do
    media = find_or_create_attachment
    updated = client.update_media(media.id, title: "Totally updated media")
    expect(updated.title).to eq "Totally updated media"
  end

  it "can be listed" do
    find_or_create_attachment

    media = client.media(per_page: 1)

    expect(media.size).to be > 0
    expect(media.first).to be_instance_of(Wpclient::Media)
  end

  def find_or_create_attachment
    client.media(per_page: 1).first || open_fixture("thoughtful.jpg") do |file|
      client.upload_file(file, mime_type: "image/jpeg", filename: "thoughtful.jpg")
    end
  end
end
