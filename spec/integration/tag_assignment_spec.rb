require "spec_helper"

describe "Tag assignment" do
  setup_integration_client
  let(:existing_post) { find_existing_post }

  it "can be set for multiple tags when creating a post" do
    tag = client.create_tag(name: "Assignment test 1")
    post = client.create_post(tag_ids: [tag.id], title: "Assignment test")

    expect(post.tags).to eq [tag]
  end

  it "can be changed when updating a post" do
    tag = client.create_tag(name: "Assignment test 2")
    post = find_existing_post

    client.update_post(post.id, tag_ids: [tag.id])

    post = client.find_post(post.id)
    expect(post.tags).to eq [tag]
  end

  def find_existing_post
    posts = client.posts(per_page: 1)
    expect(posts).to_not be_empty
    posts.first
  end
end
