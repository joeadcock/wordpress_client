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
      get_json("posts", page: page, per_page: per_page, _embed: nil).map do |post|
        Post.new(post)
      end
    rescue Faraday::TimeoutError
      raise TimeoutError
    end

    def categories(per_page: 10, page: 1)
      get_json("terms/category", page: page, per_page: per_page).map do |category|
        Category.parse(category)
      end
    end

    def get_post(id)
      post = get_json("posts/#{id.to_i}", _embed: nil)
      Post.new(post)
    end

    def find_by_slug(slug)
      posts = get_json("posts", filter: {name: slug}, _embed: nil)
      if posts.size > 0
        Post.new(posts.first)
      else
        raise NotFoundError, "Could not find post with slug #{slug.to_s.inspect}"
      end
    end

    def create_post(data)
      response = post_json("posts", data)
      if response.status == 201
        post = get_json(response.headers.fetch("location"), _embed: nil)
        Post.new(post)
      else
        handle_status_code(response)
        # If we get here, the status code was successful, but not 201 (handled
        # above). This should not happen.
        raise ServerError, "Got unexpected response from server: #{response.status}"
      end
    end

    def update_post(id, data)
      post = parse_json_response(post_json("posts/#{id.to_i}", data, method: :patch))
      Post.new(post)
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

    def post_json(path, data, method: :post)
      json = data.to_json
      connection.public_send(method) do |request|
        request.url path
        request.headers["Content-Type"] = "application/json; charset=#{json.encoding}"
        request.body = json
      end
    end

    def get_json(path, params = {})
      parse_json_response(connection.get(path, params))
    end

    def parse_json_response(response)
      handle_status_code(response)

      content_type = response.headers["content-type"].split(";").first
      unless content_type == "application/json"
        raise ServerError, "Got content type #{content_type}"
      end

      JSON.parse(response.body)

    rescue JSON::ParserError => error
      raise ServerError, "Could not parse JSON response: #{error}"
    end

    def handle_status_code(response)
      case response.status
      when 200 then return

      when 404
        raise NotFoundError, "Could not find resource"

      when 400
        handle_bad_request(response)

      else
        raise ServerError, "Server returned status code #{response.status}: #{response.body}"
      end
    end

    def handle_bad_request(response)
      code, message = bad_request_details(response)
      if code == "rest_post_invalid_id"
        raise NotFoundError, "Post ID is not found"
      else
        raise ValidationError, message
      end
    end

    def bad_request_details(response)
      details = JSON.parse(response.body).first
      [details["code"], details["message"]]
    rescue
      [nil, "Bad Request"]
    end
  end
end
