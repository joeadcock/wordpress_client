require "spec_helper"

module Wpclient
  describe ReplaceCategories do
    let(:client) { double(Client) }
    before { allow(client).to receive(:find_post) }

    it "returns the updated post" do
      updated_post = double(Post)
      original_post = double(Post, id: 5, category_ids: [])
      expect(client).to receive(:find_post).with(5).and_return(updated_post)

      result = ReplaceCategories.call(client, original_post, [])
      expect(result).to eq updated_post
    end

    it "adds missing categories" do
      post = double(Post, id: 40, category_ids: [1])

      expect(client).to receive(:assign_category_to_post).with(post_id: 40, category_id: 5)

      ReplaceCategories.call(client, post, [1, 5])
    end

    it "removes extra categories" do
      post = double(Post, id: 40, category_ids: [8, 9, 10])

      expect(client).to receive(:remove_category_from_post).with(post_id: 40, category_id: 8)
      expect(client).to receive(:remove_category_from_post).with(post_id: 40, category_id: 9)

      ReplaceCategories.call(client, post, [10])
    end
  end
end
