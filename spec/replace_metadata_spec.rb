require "spec_helper"

module Wpclient
  describe ReplaceMetadata do
    it "adds missing metadata" do
      client = instance_double(Client)
      post = instance_double(Post, id: 5, meta: {"existing" => "1"})

      expect(client).to receive(:assign_meta_to_post).with(post_id: 5, key: "new", value: "2")

      ReplaceMetadata.call(client, post, existing: "1", new: "2")
    end

    it "replaces changed metadata" do
      client = instance_double(Client)
      post = instance_double(Post, id: 5, meta: {"change_me" => "1"})

      expect(post).to receive(:meta_id_for).with("change_me").and_return(13)

      expect(client).to receive(:update_meta_on_post).with(
        post_id: 5, meta_id: 13, key: "change_me", value: "2"
      )

      ReplaceMetadata.call(client, post, change_me: "2")
    end

    it "removes extra metadata" do
      client = instance_double(Client)
      post = instance_double(Post, id: 5, meta: {"old" => "1", "new" => "2"})

      expect(post).to receive(:meta_id_for).with("old").and_return(45)
      expect(client).to receive(:remove_meta_from_post).with(post_id: 5, meta_id: 45)

      ReplaceMetadata.call(client, post, new: "2")
    end
  end
end
