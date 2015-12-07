require "spec_helper"
require "shared_examples/term_examples"

module WordpressClient
  describe Tag do
    it_behaves_like Term, fixture_name: "tag.json"
  end
end
