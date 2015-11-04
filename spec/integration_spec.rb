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
end
