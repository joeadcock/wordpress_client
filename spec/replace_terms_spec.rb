require "spec_helper"

module Wpclient
  describe ReplaceTerms do
    it "adds missing categories" do
      connection = double(Connection)
      post = double(Post, id: 40, category_ids: [1])

      expect(connection).to receive(:create_without_response).with("posts/40/terms/category/5", {})

      ReplaceTerms.apply_categories(connection, post, [1, 5])
    end

    it "removes extra categories" do
      connection = double(Connection)
      post = double(Post, id: 40, category_ids: [8, 9, 10])

      expect(connection).to receive(:delete).with("posts/40/terms/category/8", force: true)
      expect(connection).to receive(:delete).with("posts/40/terms/category/9", force: true)

      ReplaceTerms.apply_categories(connection, post, [10])
    end

    it "adds missing tags" do
      connection = double(Connection)
      post = double(Post, id: 40, tag_ids: [1])

      expect(connection).to receive(:create_without_response).with("posts/40/terms/tag/5", {})

      ReplaceTerms.apply_tags(connection, post, [1, 5])
    end

    it "removes extra tags" do
      connection = double(Connection)
      post = double(Post, id: 40, tag_ids: [8, 9, 10])

      expect(connection).to receive(:delete).with("posts/40/terms/tag/8", force: true)
      expect(connection).to receive(:delete).with("posts/40/terms/tag/9", force: true)

      ReplaceTerms.apply_tags(connection, post, [10])
    end

    it "returns the amount of changes made" do
      connection = double(Connection).as_null_object
      post = double(Post, id: 40, tag_ids: [8, 9, 10])

      result = ReplaceTerms.apply_tags(connection, post, [10, 11])
      expect(result).to eq 3
    end
  end
end
