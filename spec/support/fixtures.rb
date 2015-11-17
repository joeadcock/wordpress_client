module Fixtures
  FixtureRoot = Pathname.new(File.expand_path("../../fixtures", __FILE__))

  def fixture_contents(name)
    FixtureRoot.join(name).read
  end

  def json_fixture(name)
    JSON.parse(fixture_contents(name))
  end

  def open_fixture(name)
    FixtureRoot.join(name).open('r') { |file| yield file }
  end
end
