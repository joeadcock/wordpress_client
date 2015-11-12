module IntegrationMacros
  def setup_integration_client
    before { WebMock.allow_net_connect! }

    let(:client) {
      server = WordpressServer.instance
      Wpclient.new(url: server.url, username: server.username, password: server.password)
    }
  end
end
