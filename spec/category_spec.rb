require "spec_helper"
require "shared_examples/term_examples"

module WordpressClient
  describe Category do
    it_behaves_like Term, fixture_name: "category.json"
  end
end
