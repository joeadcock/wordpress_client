require "spec_helper"

module Wpclient
  describe Connection do
    it "is constructed with a url, username and a password" do
      connection = Connection.new(
        url: "http://example.com/wp-json", username: "jane", password: "doe"
      )

      expect(connection.url).to eq('http://example.com/wp-json')
    end

    it "does not show password when inspected" do
      connection = Connection.new(url: "/", username: "x", password: "secret")
      expect(connection.to_s).to_not include "secret"
      expect(connection.inspect).to_not include "secret"
    end
  end
end
