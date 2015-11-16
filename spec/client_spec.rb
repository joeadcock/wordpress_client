require "spec_helper"

describe Wpclient::Client do
  subject(:client) { Wpclient::Client.new(connection) }
  let(:connection) { instance_double(Wpclient::Connection) }

  describe "finding posts" do
    it "has working pagination" do
      expect(connection).to receive(:get_multiple).with(
        Wpclient::Post, "posts", hash_including(page: 2, per_page: 13)
      ).and_return []

      expect(client.posts(per_page: 13, page: 2)).to eq []
    end

    it "embeds linked resources" do
      expect(connection).to receive(:get_multiple).with(
        Wpclient::Post, "posts", hash_including(_embed: nil)
      ).and_return []

      expect(client.posts).to eq []
    end
  end

  describe "fetching a single post" do
    it "embeds linked resources" do
      post = instance_double(Wpclient::Post)

      expect(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", _embed: nil
      ).and_return post

      expect(client.find_post(5)).to eq post
    end

    it "can find using a slug" do
      post = instance_double(Wpclient::Post)

      expect(connection).to receive(:get_multiple).with(
        Wpclient::Post, "posts", hash_including(filter: {name: "my-slug"})
      ).and_return [post]

      expect(client.find_by_slug("my-slug")).to eq post
    end

    it "raises NotFoundError when trying to find by slug yields no posts" do
      expect(connection).to receive(:get_multiple).with(
        Wpclient::Post, "posts", hash_including(filter: {name: "my-slug"}, per_page: 1)
      ).and_return []

      expect {
        client.find_by_slug("my-slug")
      }.to raise_error(Wpclient::NotFoundError, /my-slug/)
    end
  end

  describe "creating a post" do
    it "embeds linked resources when following redirect" do
      post = instance_double(Wpclient::Post, id: 5)
      attributes = {title: "Foo"}

      expect(connection).to receive(:create).with(
        Wpclient::Post, "posts", attributes, redirect_params: {_embed: nil}
      ).and_return post

      # We don't expect here as the `create` call below could be enough, but
      # it's also very possible that we need to fetch the post again after
      # doing other things to it.
      allow(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", hash_including(_embed: nil)
      ).and_return(post)

      expect(client.create_post(attributes)).to eq post
    end

    it "adds metadata to the post"
    it "changes categories of the post"
  end

  describe "updating a post" do
    it "embeds linked resources" do
      post = instance_double(Wpclient::Post)

      expect(connection).to receive(:patch).with(
        Wpclient::Post, "posts/5?_embed", hash_including(title: "Foo")
      ).and_return(post)

      expect(client.update_post(5, title: "Foo")).to eq post
    end

    it "adds metadata to the post"
    it "changes categories of the post"
  end

  describe "categories" do
    it "can be listed"
    it "can be created"
    it "can be updated"
    it "can be deleted"
  end
end
