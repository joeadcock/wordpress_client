require "spec_helper"

describe "Tags" do
  setup_integration_client

  it "is listed on found posts" do
    pending
    post = client.posts(per_page: 1).first

    expect(post.tags).to_not be_empty

    tag = post.tags.first
    expect(tag.id).to be_kind_of(Integer)
    expect(tag.name).to be_instance_of(String)
    expect(tag.slug).to be_instance_of(String)

    expect(post.tag_ids).to eq post.tags.map(&:id)
  end

  it "can be found" do
    existing = find_or_create_tag
    expect(client.find_tag(existing.id)).to eq existing
  end

  it "can be created" do
    tag = client.create_tag(name: "New tag")

    expect(tag.id).to be_kind_of(Integer)
    expect(tag.name).to eq "New tag"
    expect(tag.slug).to eq "new-tag"

    expect(client.tags(per_page: 100).map(&:name)).to include "New tag"
  end

  it "can be updated" do
    existing = find_or_create_tag
    client.update_tag(existing.id, name: "Updated name")
    expect(client.find_tag(existing.id).name).to eq "Updated name"
  end

  def find_or_create_tag
    tags = client.tags(per_page: 1)
    tags.first || client.create_tag(name: "Autocreated")
  end
end
