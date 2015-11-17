require "spec_helper"
require "shared_examples/term_examples"

describe Wpclient::Tag do
  it_behaves_like Wpclient::Term, fixture_name: "tag.json"
end
