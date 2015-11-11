require "spec_helper"

describe "Category assignment" do
  before { WebMock.allow_net_connect! }

  let(:client) {
    server = WordpressServer.instance
    Wpclient.new(url: server.url, username: server.username, password: server.password)
  }

  let(:existing_post) { find_existing_post }

  it "is possible on a post" do
    new_category = client.create_category(name: "Post assignment 1")
    client.assign_category_to_post(post_id: existing_post.id, category_id: new_category.id)
    expect(client.get_post(existing_post.id).categories).to include new_category
  end

  it "can be removed on a post" do
    new_category = client.create_category(name: "Post assignment 2")
    client.assign_category_to_post(post_id: existing_post.id, category_id: new_category.id)

    client.remove_category_from_post(post_id: existing_post.id, category_id: new_category.id)
    expect(client.get_post(existing_post.id).categories).to_not include(new_category)
  end

  it "can be set for multiple categories when creating a post" do
    category = client.create_category(name: "Assignment test 1")
    post = client.create_post(category_ids: [category.id], title: "Assignment test")

    expect(post.categories).to eq [category]
  end

  it "can be changed when updating a post" do
    category = client.create_category(name: "Assignment test 2")
    post = find_existing_post

    client.update_post(post.id, category_ids: [category.id])

    post = client.get_post(post.id)
    expect(post.categories).to eq [category]
  end

  def find_existing_post
    posts = client.posts(per_page: 1)
    expect(posts).to_not be_empty
    posts.first
  end
end
