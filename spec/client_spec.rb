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

  it "can send requests to the URL" do
    request_stub = stub_request(
      :get, "http://myself:mysecret@example.com/wp-json/wp/v2/posts?per_page=13&page=2"
    ).to_return(body: "[]", headers: {"content-type" => "application/json"})

    client = Wpclient.new(
      url: "http://example.com/wp-json", username: "myself", password: "mysecret"
    )

    posts = client.posts(per_page: 13, page: 2)

    expect(request_stub).to have_been_made
    expect(posts).to eq []
  end
end
