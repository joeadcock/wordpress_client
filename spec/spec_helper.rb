$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require "webmock/rspec"
require "wpclient"

require_relative "support/docker_runner"

RSpec.configure do |config|
  config.include DockerRunner
end
