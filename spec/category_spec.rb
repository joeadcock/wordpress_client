require "spec_helper"
require "shared_examples/term_examples"

describe Wpclient::Category do
  it_behaves_like Wpclient::Term, fixture_name: "category.json"
end
