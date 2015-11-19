module Fixtures
  FixtureRoot = Pathname.new(File.expand_path("../../fixtures", __FILE__))

  def fixture_path(name)
    FixtureRoot.join(name)
  end

  def fixture_contents(name)
    fixture_path(name).read
  end

  def json_fixture(name)
    JSON.parse(fixture_contents(name))
  end

  def open_fixture(name)
    fixture_path(name).open('r') { |file| yield file }
  end
end
