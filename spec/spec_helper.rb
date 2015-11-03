$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require "webmock/rspec"
require "wpclient"

require_relative "support/docker_runner"

RSpec.configure do |config|
  config.include DockerRunner

  config.before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  config.after do
    WebMock.allow_net_connect!
  end
end
