require "spec_helper"

describe "Tags" do
  setup_integration_client

  it "can be found" do
    existing = find_or_create_tag
    expect(client.find_tag(existing.id)).to eq existing
  end

  it "can be created" do
    tag = client.create_tag(name: "New tag")

    expect(tag.id).to be_kind_of(Integer)
    expect(tag.name_html).to eq "New tag"
    expect(tag.slug).to eq "new-tag"

    expect(client.tags(per_page: 100).map(&:name_html)).to include "New tag"
  end

  it "can be updated" do
    existing = find_or_create_tag
    client.update_tag(existing.id, name: "Updated name")
    expect(client.find_tag(existing.id).name_html).to eq "Updated name"
  end

  it "uses HTML for the name" do
    tag = client.create_tag(name: "Sort & Find")
    expect(tag.name_html).to eq "Sort &amp; Find"
  end

  def find_or_create_tag
    tags = client.tags(per_page: 1)
    tags.first || client.create_tag(name: "Autocreated")
  end
end
