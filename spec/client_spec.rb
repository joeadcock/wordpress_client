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

    it "can filter on category slugs" do
      expect(connection).to receive(:get_multiple).with(
        Wpclient::Post, "posts", hash_including(filter: {category_name: "my-cat"})
      ).and_return []

      expect(client.posts(category_slug: "my-cat")).to eq []
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

    it "adds metadata to the post and refreshes" do
      post = instance_double(Wpclient::Post, id: 5)
      allow(connection).to receive(:create).and_return(post)

      expect(Wpclient::ReplaceMetadata).to receive(:call).with(
        connection, post, {"hello" => "world"}
      ).ordered

      expect(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", hash_including(_embed: nil)
      ).and_return(post).ordered

      client.create_post(title: "Foo", meta: {"hello" => "world"})
    end

    it "sets categories of the post and refreshes" do
      post = instance_double(Wpclient::Post, id: 5)
      allow(connection).to receive(:create).and_return(post)

      expect(Wpclient::ReplaceTerms).to receive(:apply_categories).with(
        connection, post, [1, 3, 7]
      ).ordered

      expect(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", hash_including(_embed: nil)
      ).and_return(post).ordered

      client.create_post(title: "Foo", category_ids: [1, 3, 7])
    end

    it "sets tags of the post and refreshes" do
      post = instance_double(Wpclient::Post, id: 5)
      allow(connection).to receive(:create).and_return(post)

      expect(Wpclient::ReplaceTerms).to receive(:apply_tags).with(
        connection, post, [1, 3, 7]
      ).ordered

      expect(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", hash_including(_embed: nil)
      ).and_return(post).ordered

      client.create_post(title: "Foo", tag_ids: [1, 3, 7])
    end
  end

  describe "updating a post" do
    it "embeds linked resources" do
      post = instance_double(Wpclient::Post)

      expect(connection).to receive(:patch).with(
        Wpclient::Post, "posts/5?_embed", hash_including(title: "Foo")
      ).and_return(post)

      expect(client.update_post(5, title: "Foo")).to eq post
    end

    it "adds metadata to the post and refreshes" do
      post = instance_double(Wpclient::Post, id: 5)
      allow(connection).to receive(:patch).and_return(post)

      expect(Wpclient::ReplaceMetadata).to receive(:call).with(
        connection, post, {"hello" => "world"}
      ).ordered

      expect(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", hash_including(_embed: nil)
      ).and_return(post).ordered

      client.update_post(5, title: "Foo", meta: {"hello" => "world"})
    end

    it "changes categories of the post and refreshes" do
      post = instance_double(Wpclient::Post, id: 5)
      allow(connection).to receive(:patch).and_return(post)

      expect(Wpclient::ReplaceTerms).to receive(:apply_categories).with(
        connection, post, [1, 3, 7]
      ).ordered

      expect(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", hash_including(_embed: nil)
      ).and_return(post).ordered

      client.update_post(5, title: "Foo", category_ids: [1, 3, 7])
    end

    it "changes tags of the post and refreshes" do
      post = instance_double(Wpclient::Post, id: 5)
      allow(connection).to receive(:patch).and_return(post)

      expect(Wpclient::ReplaceTerms).to receive(:apply_tags).with(
        connection, post, [1, 3, 7]
      ).ordered

      expect(connection).to receive(:get).with(
        Wpclient::Post, "posts/5", hash_including(_embed: nil)
      ).and_return(post).ordered

      client.update_post(5, title: "Foo", tag_ids: [1, 3, 7])
    end
  end

  describe "categories" do
    it "can be listed" do
      expect(connection).to receive(:get_multiple).with(
        Wpclient::Category, "terms/category", hash_including(page: 1, per_page: 10)
      )
      client.categories

      expect(connection).to receive(:get_multiple).with(
        Wpclient::Category, "terms/category", hash_including(page: 2, per_page: 60)
      )
      client.categories(page: 2, per_page: 60)
    end

    it "can be found" do
      category = instance_double(Wpclient::Category)

      expect(connection).to receive(:get).with(
        Wpclient::Category, "terms/category/12"
      ).and_return category

      expect(client.find_category(12)).to eq category
    end

    it "can be created" do
      category = instance_double(Wpclient::Category)

      expect(connection).to receive(:create).with(
        Wpclient::Category, "terms/category", name: "Foo"
      ).and_return category

      expect(client.create_category(name: "Foo")).to eq category
    end

    it "can be updated" do
      category = instance_double(Wpclient::Category)

      expect(connection).to receive(:patch).with(
        Wpclient::Category, "terms/category/45", name: "New"
      ).and_return category

      expect(client.update_category(45, name: "New")).to eq category
    end
  end

  describe "tags" do
    it "can be listed" do
      expect(connection).to receive(:get_multiple).with(
        Wpclient::Tag, "terms/tag", hash_including(page: 1, per_page: 10)
      )
      client.tags

      expect(connection).to receive(:get_multiple).with(
        Wpclient::Tag, "terms/tag", hash_including(page: 2, per_page: 60)
      )
      client.tags(page: 2, per_page: 60)
    end

    it "can be found" do
      tag = instance_double(Wpclient::Tag)

      expect(connection).to receive(:get).with(
        Wpclient::Tag, "terms/tag/12"
      ).and_return tag

      expect(client.find_tag(12)).to eq tag
    end

    it "can be created" do
      tag = instance_double(Wpclient::Tag)

      expect(connection).to receive(:create).with(
        Wpclient::Tag, "terms/tag", name: "Foo"
      ).and_return tag

      expect(client.create_tag(name: "Foo")).to eq tag
    end

    it "can be updated" do
      tag = instance_double(Wpclient::Tag)

      expect(connection).to receive(:patch).with(
        Wpclient::Tag, "terms/tag/45", name: "New"
      ).and_return tag

      expect(client.update_tag(45, name: "New")).to eq tag
    end
  end
end
