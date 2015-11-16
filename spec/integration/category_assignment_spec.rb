require "spec_helper"

describe "Category assignment" do
  setup_integration_client
  let(:existing_post) { find_existing_post }

  it "can be set for multiple categories when creating a post" do
    category = client.create_category(name: "Assignment test 1")
    post = client.create_post(category_ids: [category.id], title: "Assignment test")

    expect(post.categories).to eq [category]
  end

  it "can be changed when updating a post" do
    category = client.create_category(name: "Assignment test 2")
    post = find_existing_post

    client.update_post(post.id, category_ids: [category.id])

    post = client.find_post(post.id)
    expect(post.categories).to eq [category]
  end

  def find_existing_post
    posts = client.posts(per_page: 1)
    expect(posts).to_not be_empty
    posts.first
  end
end
