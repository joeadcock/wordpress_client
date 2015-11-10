require "spec_helper"

describe "Categories" do
  before { WebMock.allow_net_connect! }

  let(:client) {
    server = WordpressServer.instance
    Wpclient.new(url: server.url, username: server.username, password: server.password)
  }

  it "is listed on found posts" do
    post = client.posts(per_page: 1).first

    expect(post.categories).to_not be_empty

    category = post.categories.first
    expect(category.id).to be_kind_of(Integer)
    expect(category.name).to be_instance_of(String)
    expect(category.slug).to be_instance_of(String)

    expect(post.category_ids).to eq post.categories.map(&:id)
  end

  it "can be listed" do
    categories = client.categories
    expect(categories.size).to be > 0

    category = categories.first
    expect(category.id).to be_kind_of(Integer)
    expect(category.name).to be_instance_of(String)
    expect(category.slug).to be_instance_of(String)
  end

  it "can be created" do
    category = client.create_category(name: "New category")

    expect(category.id).to be_kind_of(Integer)
    expect(category.name).to eq "New category"
    expect(category.slug).to eq "new-category"

    expect(client.categories(per_page: 100).map(&:name)).to include "New category"
  end
end
