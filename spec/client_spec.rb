require "spec_helper"

describe Wpclient::Client do
  let(:client) { Wpclient.new(url: "http://example.com", username: "x", password: "x") }
  let(:base_url) { "http://x:x@example.com" }

  it "is initialized with connection details" do
    client = Wpclient.new(url: "https://example.com/wp-json/", username: "user", password: "secret")
    expect(client.url).to eq "https://example.com/wp-json/"
    expect(client.username).to eq "user"
  end

  it "does not show password when inspected" do
    client = Wpclient.new(url: "https://example.com/wp-json/", username: "x", password: "secret")
    expect(client.to_s).to_not include "secret"
    expect(client.inspect).to_not include "secret"
  end

  describe "finding posts" do
    it "has working pagination" do
      request_stub = stub_request(
        :get, "http://myself:mysecret@example.com/wp-json/wp/v2/posts?per_page=13&page=2&_embed"
      ).to_return(body: "[]", headers: {"content-type" => "application/json; charset=utf-8"})

      client = Wpclient.new(
        url: "http://example.com/wp-json", username: "myself", password: "mysecret"
      )

      posts = client.posts(per_page: 13, page: 2)

      expect(request_stub).to have_been_made
      expect(posts).to eq []
    end

    it "maps posts into Post instances" do
      post_fixture = json_fixture("simple-post.json")

      stub_request(:get, /./).to_return(
        headers: {"content-type" => "application/json"},
        body: [post_fixture].to_json,
      )

      client = Wpclient.new(url: "http://example.com/", username: "x", password: "x")
      post = client.posts.first

      expect(post).to be_instance_of(Wpclient::Post)
      expect(post.id).to eq post_fixture.fetch("id")
    end

    it "raises an Wpclient::TimeoutError when request times out" do
      stub_request(:get, /./).to_timeout
      expect { client.posts }.to raise_error(Wpclient::TimeoutError)
    end

    it "raises an Wpclient::ServerError when request body is broken" do
      stub_request(:get, /./).to_return(
        headers: {"content-type" => "application/json"},
        body: "[",
      )
      expect { client.posts }.to raise_error(Wpclient::ServerError, /parse/i)
    end

    it "raises an Wpclient::ServerError when response body isn't JSON" do
      stub_request(:get, /./).to_return(
        headers: {"content-type" => "text/html"},
        body: "[]",
      )
      expect { client.posts }.to raise_error(Wpclient::ServerError, /html/i)
    end

    it "raises an Wpclient::ServerError when response isn't OK" do
      stub_request(:get, /./).to_return(
        status: 401,
        headers: {"content-type" => "application/json"},
        body: "[]",
      )
      expect { client.posts }.to raise_error(Wpclient::ServerError, /401/i)
    end
  end

  describe "fetching a single post" do
    it "GETS the post ID" do
      post_fixture = json_fixture("simple-post.json")
      id = post_fixture.fetch("id")

      stub_request(:get, "#{base_url}/wp/v2/posts/#{id}?_embed").to_return(
        headers: {"content-type" => "application/json; charset=utf-8"},
        body: post_fixture.to_json,
      )

      post = client.find_post(id)
      expect(post).to be_instance_of(Wpclient::Post)
      expect(post.id).to eq id
      expect(post.title).to eq Wpclient::Post.new(post_fixture).title
    end

    it "raises a Wpclient::NotFoundError when post cannot be found" do
      stub_request(:get, "#{base_url}/wp/v2/posts/5?_embed").to_return(status: 404)

      expect { client.find_post(5) }.to raise_error(Wpclient::NotFoundError)
    end
  end

  describe "creating a post" do
    it "POSTS the data to the server" do
      post_fixture = json_fixture("simple-post.json")
      id = post_fixture.fetch("id")
      encoding = "".encoding

      stub_request(:post, "#{base_url}/wp/v2/posts").with(
        headers: {"content-type" => "application/json; charset=#{encoding}"},
        body: {"title" => "Foo"}.to_json,
      ).to_return(
        status: 201, # Created
        headers: {
          "Content-Type" => "application/json; charset=utf-8",
          "Location" => "#{base_url}/wp/v2/posts/#{id}"
        }
      )

      stub_request(:get, "#{base_url}/wp/v2/posts/#{id}?_embed").to_return(
        headers: {"content-type" => "application/json; charset=utf-8"},
        body: post_fixture.to_json,
      )

      response = client.create_post(title: "Foo")
      expect(response).to be_instance_of(Wpclient::Post)
      expect(response.id).to eq id
    end

    it "raises validation error when post could not be created" do
      error_contents = json_fixture("validation-error.json")

      stub_request(:any, /./).to_return(
        status: 400,
        headers: {"content-type" => "application/json"},
        body: error_contents.to_json,
      )

      expect {
        client.create_post({})
      }.to raise_error(Wpclient::ValidationError, error_contents.first.fetch("message"))
    end
  end

  describe "updating a post" do
    it "sends the diff as a PATCH on the post resource" do
      post_fixture = json_fixture("simple-post.json")
      encoding = "".encoding

      stub_request(:patch, "#{base_url}/wp/v2/posts/42?_embed").with(
        headers: {"content-type" => "application/json; charset=#{encoding}"},
        body: {title: "New title"}.to_json,
      ).to_return(
        headers: {"content-type" => "application/json"},
        body: post_fixture.to_json,
      )

      post = client.update_post(42, title: "New title")
      expect(post).to be_instance_of(Wpclient::Post)
      expect(post.title).to eq Wpclient::Post.new(post_fixture).title
    end

    it "raises ValidationError when server rejects changes" do
      error_contents = json_fixture("validation-error.json")

      stub_request(:any, /./).to_return(
        status: 400,
        headers: {"content-type" => "application/json"},
        body: error_contents.to_json,
      )

      expect {
        client.update_post(1, {})
      }.to raise_error(Wpclient::ValidationError, error_contents.first.fetch("message"))
    end

    it "raises NotFound when trying to update non-existing ID" do
      error_contents = json_fixture("invalid-post-id.json")

      stub_request(:any, /./).to_return(
        status: 400,
        headers: {"content-type" => "application/json"},
        body: error_contents.to_json,
      )

      expect {
        client.update_post(1, {})
      }.to raise_error(Wpclient::NotFoundError, "Post ID is not found")
    end
  end
end
