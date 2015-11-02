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
end
