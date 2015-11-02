module Wpclient
  class Client
    attr_reader :url, :username

    def initialize(url:, username:, password:)
      @url = url
      @username = username
      @password = password
    end

    def inspect
      "#<Wpclient::Client #@username @ #@url>"
    end
  end
end
