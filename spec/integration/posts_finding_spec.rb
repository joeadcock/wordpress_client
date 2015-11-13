require "spec_helper"

describe "Posts (finding)" do
  setup_integration_client

  describe "finding by slug" do
    it "finds the matching post" do
      post = client.create_post(title: "Oh hai", slug: "oh-hai")
      found = client.find_by_slug("oh-hai")
      expect(found.id).to eq post.id
    end

    it "raises NotFoundError when no post can be found" do
      expect {
        client.find_by_slug("clearly-does-not-exist-anywhere")
      }.to raise_error(Wpclient::NotFoundError, /clearly/)
    end

    it "finds on the slug even if the title is wildly different" do
      post = client.create_post(
        title: "Updated title that doesn't match slug",
        slug: "original-concise-title",
      )
      found = client.find_by_slug("original-concise-title")
      expect(found.id).to eq post.id
    end
  end
end
