require "spec_helper"

describe Wpclient::Client do
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
        :get, "http://myself:mysecret@example.com/wp-json/wp/v2/posts?per_page=13&page=2"
      ).to_return(body: "[]", headers: {"content-type" => "application/json; charset=utf-8"})

      client = Wpclient.new(
        url: "http://example.com/wp-json", username: "myself", password: "mysecret"
      )

      posts = client.posts(per_page: 13, page: 2)

      expect(request_stub).to have_been_made
      expect(posts).to eq []
    end

    it "maps posts into Post instances" do
      fixture_post = json_fixture("simple-post.json")

      stub_request(:get, %r{.}).to_return(
        headers: {"content-type" => "application/json"},
        body: [fixture_post].to_json,
      )

      client = Wpclient.new(url: "http://example.com/", username: "x", password: "x")
      post = client.posts.first

      expect(post).to be_instance_of(Wpclient::Post)
      expect(post.id).to eq fixture_post.fetch("id")
    end

    it "raises an Wpclient::TimeoutError when request times out" do
      stub_request(:get, %r{.}).to_timeout
      expect { make_client.posts }.to raise_error(Wpclient::TimeoutError)
    end

    it "raises an Wpclient::ServerError when request body is broken" do
      stub_request(:get, %r{.}).to_return(
        headers: {"content-type" => "application/json"},
        body: "[",
      )
      expect { make_client.posts }.to raise_error(Wpclient::ServerError, /parse/i)
    end

    it "raises an Wpclient::ServerError when response body isn't JSON" do
      stub_request(:get, %r{.}).to_return(
        headers: {"content-type" => "text/html"},
        body: "[]",
      )
      expect { make_client.posts }.to raise_error(Wpclient::ServerError, /html/i)
    end

    it "raises an Wpclient::ServerError when response isn't OK" do
      stub_request(:get, %r{.}).to_return(
        status: 401,
        headers: {"content-type" => "application/json"},
        body: "[]",
      )
      expect { make_client.posts }.to raise_error(Wpclient::ServerError, /401/i)
    end

    def make_client
      Wpclient.new(url: "http://example.com", username: "x", password: "x")
    end
  end
end
