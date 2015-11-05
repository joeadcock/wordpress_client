require "spec_helper"

describe "integration tests" do
  before(:all) do
    @server = start_wordpress_server
  end

  before do
    WebMock.allow_net_connect!
  end

  it "can list posts" do
    client = Wpclient.new(url: @server.url, username: @server.username, password: @server.password)

    posts = client.posts(per_page: 1)
    expect(posts.size).to be 1

    post = posts.first
    expect(post).to be_instance_of Wpclient::Post
    expect(post.title).to eq "Hello world!"
  end

  it "can create a post" do
    client = Wpclient.new(url: @server.url, username: @server.username, password: @server.password)

    data = {
      title: "A newly created post",
      status: "publish",
    }

    post = client.create_post(data)

    expect(post.id).to be_kind_of Integer

    # Try to find the post to determine if it was persisted or not
    all_posts = client.posts(per_page: 100)
    expect(all_posts.map(&:id)).to include post.id
    expect(all_posts.map(&:title)).to include "A newly created post"
  end
end
