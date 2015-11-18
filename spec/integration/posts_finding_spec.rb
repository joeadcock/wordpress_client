require "spec_helper"

describe "Posts (finding)" do
  setup_integration_client

  it "sorts on publication date by default" do
    client.create_post(status: "publish", date: "2012-05-05T15:00:00Z", title: "Oldest")
    client.create_post(status: "publish", date: "2012-06-15T15:00:00Z", title: "Newest")
    client.create_post(status: "publish", date: "2012-05-20T15:00:00Z", title: "Older")

    posts = client.posts(per_page: 10)

    expect(posts.first.date).to be > posts.last.date
    expect(posts.map(&:id)).to eq posts.sort_by(&:date).reverse.map(&:id)
  end

  it "can list articles in a specific category" do
    category = client.create_category(name: "Filtering time", slug: "filtering")
    post = client.create_post(
      category_ids: [category.id],
      status: "publish",
      title: "Some title",
    )

    expect(client.posts(category_slug: "filtering").map(&:id)).to eq [post.id]
  end

  it "can list articles in a specific tag" do
    tag = client.create_tag(name: "Taggged", slug: "tagged")
    post = client.create_post(
      tag_ids: [tag.id],
      status: "publish",
      title: "Some title",
    )

    expect(client.posts(tag_slug: "tagged").map(&:id)).to eq [post.id]
  end

  it "can list articles in a specific tag and category" do
    category = client.create_category(name: "Fishing", slug: "fish")
    tag = client.create_tag(name: "Soup", slug: "soup")
    post = client.create_post(
      category_ids: [category.id],
      tag_ids: [tag.id],
      status: "publish",
      title: "Some title",
    )

    _post_without_tag = client.create_post(
      category_ids: [category.id],
      status: "publish",
      title: "Some title",
    )

    _post_without_category = client.create_post(
      tag_ids: [tag.id],
      status: "publish",
      title: "Some title",
    )

    expect(client.posts(category_slug: "fish", tag_slug: "soup").map(&:id)).to eq [post.id]
  end

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
