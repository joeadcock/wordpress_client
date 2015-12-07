if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require "webmock/rspec"

require_relative "support/wordpress_server"
require_relative "support/fixtures"
require_relative "support/integration_macros"

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require "wordpress_client"

RSpec.configure do |config|
  config.extend IntegrationMacros
  config.include Fixtures

  config.run_all_when_everything_filtered = true

  config.before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  config.after do
    WebMock.allow_net_connect!
  end
end
