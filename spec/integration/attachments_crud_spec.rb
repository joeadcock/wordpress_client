require "spec_helper"

describe "Attachments" do
  setup_integration_client

  it "can be created" do
    media = open_fixture("thoughtful.jpg") do |file|
      client.upload_file(file, mime_type: "image/jpeg", filename: "thoughtful.jpg")
    end

    expect(media).to be_instance_of(Wpclient::Media)

    pending
    expect(client.find_media(media.id)).to be_instance_of(Wpclient::Media)
  end

  it "can be updated" do
    pending
    media = find_or_create_attachment

    updated = client.update_media(media.id, title: "#{media.title} 2")

    expect(updated.title).to eq "#{media.title} 2"
  end

  it "can be listed" do
    pending
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
