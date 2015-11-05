require "spec_helper"

describe "integration tests" do
  before(:all) do
    @server = start_wordpress_server
  end

  before do
    WebMock.allow_net_connect!
  end

  let(:client) { Wpclient.new(url: @server.url, username: @server.username, password: @server.password) }

  it "can list posts" do
    posts = client.posts(per_page: 1)
    expect(posts.size).to be 1

    post = posts.first
    expect(post).to be_instance_of Wpclient::Post
    expect(post.title).to eq "Hello world!"
  end

  it "can get specific posts" do
    posts = client.posts(per_page: 1)
    expect(posts).to_not be_empty

    first_post = posts.first

    post = client.get_post(first_post.id)
    expect(post.id).to eq first_post.id
    expect(post.title).to eq first_post.title

    expect { client.get_post(888888) }.to raise_error(Wpclient::NotFoundError)
  end

  it "can create a post" do
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
