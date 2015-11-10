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
  end
end
