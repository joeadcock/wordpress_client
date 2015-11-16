require "spec_helper"

module Wpclient
  describe ReplaceCategories do
    it "adds missing categories" do
      connection = double(Connection)
      post = double(Post, id: 40, category_ids: [1])

      expect(connection).to receive(:create_without_response).with("posts/40/terms/category/5", {})

      ReplaceCategories.call(connection, post, [1, 5])
    end

    it "removes extra categories" do
      connection = double(Connection)
      post = double(Post, id: 40, category_ids: [8, 9, 10])

      expect(connection).to receive(:delete).with("posts/40/terms/category/8", force: true)
      expect(connection).to receive(:delete).with("posts/40/terms/category/9", force: true)

      ReplaceCategories.call(connection, post, [10])
    end
  end
end
