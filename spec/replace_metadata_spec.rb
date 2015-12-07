require "spec_helper"

module WordpressClient
  describe ReplaceMetadata do
    it "does nothing if the new metadata is equal to the existing one" do
      post = instance_double(Post, id: 5, meta: {"existing" => "1"})

      # Note: connection double does not accept any message.
      connection = instance_double(Connection)

      ReplaceMetadata.apply(connection, post, existing: "1")
    end

    it "adds missing metadata" do
      connection = instance_double(Connection)
      post = instance_double(Post, id: 5, meta: {"existing" => "1"})

      expect(connection).to receive(:create_without_response).with(
        "posts/5/meta", key: "new", value: "2"
      )

      ReplaceMetadata.apply(connection, post, existing: "1", new: "2")
    end

    it "replaces changed metadata" do
      connection = instance_double(Connection)
      post = instance_double(Post, id: 5, meta: {"change_me" => "1"})

      expect(post).to receive(:meta_id_for).with("change_me").and_return(13)

      expect(connection).to receive(:patch_without_response).with(
        "posts/5/meta/13", key: "change_me", value: "2"
      )

      ReplaceMetadata.apply(connection, post, change_me: "2")
    end

    it "removes extra metadata" do
      connection = instance_double(Connection)
      post = instance_double(Post, id: 5, meta: {"old" => "1", "new" => "2"})

      expect(post).to receive(:meta_id_for).with("old").and_return(45)
      expect(connection).to receive(:delete).with("posts/5/meta/45", force: true)

      ReplaceMetadata.apply(connection, post, new: "2")
    end

    it "returns the number of changes" do
      connection = instance_double(Connection).as_null_object
      post = instance_double(Post, id: 5, meta: {"old" => "1", "change" => "2"}).as_null_object

      result = ReplaceMetadata.apply(connection, post, change: "3", extra: "4")
      expect(result).to eq 3
    end
  end
end
