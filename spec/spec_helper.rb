if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require "webmock/rspec"
require "wpclient"

require_relative "support/wordpress_server"
require_relative "support/fixtures"
require_relative "support/integration_macros"

RSpec.configure do |config|
  config.extend IntegrationMacros
  config.include Fixtures

  config.before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  config.after do
    WebMock.allow_net_connect!
  end
end
