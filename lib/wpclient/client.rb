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
      parse_json_response(
        connection.get("posts", page: page, per_page: per_page)
      ).map do |post|
        Post.new(post)
      end
    rescue Faraday::TimeoutError
      raise Wpclient::TimeoutError
    end

    def get_post(id)
      post = parse_json_response(connection.get("posts/#{id.to_i}"))
      Post.new(post)
    end

    def create_post(data)
      response = post_json("posts", data)
      if response.status == 201
        post = parse_json_response(connection.get(response.headers.fetch("location")))
        Post.new(post)
      end
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

    def post_json(path, data)
      json = data.to_json
      connection.post do |request|
        request.url path
        request.headers["Content-Type"] = "application/json; charset=#{json.encoding}"
        request.body = json
      end
    end

    def parse_json_response(response)
      handle_status_code(response)

      content_type = response.headers["content-type"].split(";").first
      unless content_type == "application/json"
        raise Wpclient::ServerError, "Got content type #{content_type}"
      end

      JSON.parse(response.body)

    rescue JSON::ParserError => error
      raise Wpclient::ServerError, "Could not parse JSON response: #{error}"
    end

    def handle_status_code(response)
      case response.status
      when 200 then return

      when 404
        raise NotFoundError, "Could not find resource"

      else
        raise ServerError, "Server returned status code #{response.status}"
      end
    end
  end
end
