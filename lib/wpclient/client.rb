require "faraday"

module Wpclient
  class Client
    attr_reader :url, :username

    def initialize(url:, username:, password:)
      @url = url
      @username = username
      @password = password
    end

    def posts(per_page: 10, page: 1)
      JSON.parse(connection.get("posts", page: page, per_page: per_page).body)
    end

    def inspect
      "#<Wpclient::Client #@username @ #@url>"
    end

    private
    def connection
      @connection ||= create_connection
    end

    def create_connection
      Faraday.new(url: "#{url}/wp/v2") do |conn|
        conn.request :basic_auth, username, @password
        conn.adapter :net_http
      end
    end
  end
end
