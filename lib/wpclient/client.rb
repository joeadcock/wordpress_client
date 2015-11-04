require "faraday"
require "json"

module Wpclient
  class Client
    attr_reader :url, :username

    def initialize(url:, username:, password:)
      @url = url
      @username = username
      @password = password
    end

    def posts(per_page: 10, page: 1)
      parse_json_response connection.get("posts", page: page, per_page: per_page)
    rescue Faraday::TimeoutError
      raise Wpclient::TimeoutError
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

    def parse_json_response(response)
      raise Wpclient::ServerError, "Server returned #{response.status}" if response.status != 200

      content_type = response.headers["content-type"].split(";").first
      unless content_type == "application/json"
        raise Wpclient::ServerError, "Got content type #{content_type}"
      end

      JSON.parse(response.body)

    rescue JSON::ParserError => error
      raise Wpclient::ServerError, "Could not parse JSON response: #{error}"
    end
  end
end
