require "spec_helper"

describe "integration tests" do
  before(:all) do
    @server = start_wordpress_server
  end

  it "works" do
    expect(true).to be true
  end
end
