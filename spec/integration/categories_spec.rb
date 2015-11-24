require "spec_helper"

describe "Categories" do
  setup_integration_client

  it "is listed on found posts" do
    post = client.posts(per_page: 1).first

    expect(post.categories).to_not be_empty

    category = post.categories.first
    expect(category.id).to be_kind_of(Integer)
    expect(category.name_html).to be_instance_of(String)
    expect(category.slug).to be_instance_of(String)

    expect(post.category_ids).to eq post.categories.map(&:id)
  end

  it "can be listed" do
    categories = client.categories
    expect(categories.size).to be > 0

    category = categories.first
    expect(category.id).to be_kind_of(Integer)
    expect(category.name_html).to be_instance_of(String)
    expect(category.slug).to be_instance_of(String)
  end

  it "can be found" do
    existing = find_existing_category
    expect(client.find_category(existing.id)).to eq existing
  end

  it "can be created" do
    category = client.create_category(name: "New category")

    expect(category.id).to be_kind_of(Integer)
    expect(category.name_html).to eq "New category"
    expect(category.slug).to eq "new-category"

    expect(client.categories(per_page: 100).map(&:name_html)).to include "New category"
  end

  it "can be updated" do
    existing = find_existing_category
    client.update_category(existing.id, name: "Updated name")
    expect(client.find_category(existing.id).name_html).to eq "Updated name"
  end

  it "uses HTML for the name" do
    category = client.create_category(name: "Sort & Find")
    expect(category.name_html).to eq "Sort &amp; Find"
  end

  def find_existing_category
    categories = client.categories(per_page: 1)
    expect(categories).to_not be_empty
    categories.first
  end
end
