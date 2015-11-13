require "spec_helper"

module Wpclient
  describe ReplaceCategories do
    it "adds missing categories" do
      client = double(Client)
      post = double(Post, id: 40, category_ids: [1])

      expect(client).to receive(:assign_category_to_post).with(post_id: 40, category_id: 5)

      ReplaceCategories.call(client, post, [1, 5])
    end

    it "removes extra categories" do
      client = double(Client)
      post = double(Post, id: 40, category_ids: [8, 9, 10])

      expect(client).to receive(:remove_category_from_post).with(post_id: 40, category_id: 8)
      expect(client).to receive(:remove_category_from_post).with(post_id: 40, category_id: 9)

      ReplaceCategories.call(client, post, [10])
    end
  end
end
