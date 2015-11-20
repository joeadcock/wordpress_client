require "spec_helper"

describe "Posts (CRUD)" do
  setup_integration_client

  it "can list posts" do
    posts = client.posts(per_page: 1)
    expect(posts.size).to be 1

    post = posts.first
    expect(post).to be_instance_of Wpclient::Post
    expect(post.title).to be_instance_of(String)
  end

  it "can get specific posts" do
    existing_post = find_existing_post

    found_post = client.find_post(existing_post.id)
    expect(found_post.id).to eq existing_post.id
    expect(found_post.title).to eq existing_post.title

    expect { client.find_post(888888) }.to raise_error(Wpclient::NotFoundError)
  end

  it "can create a post" do
    data = {
      title: "A newly created post",
      status: "publish",
    }

    post = client.create_post(data)

    expect(post.id).to be_kind_of Integer

    # Try to find the post to determine if it was persisted or not
    all_posts = client.posts(per_page: 100)
    expect(all_posts.map(&:id)).to include post.id
    expect(all_posts.map(&:title)).to include "A newly created post"
  end

  it "raises a validation error if post could not be created" do
    expect {
      client.create_post(status: "not really valid")
    }.to raise_error(Wpclient::ValidationError, /status/)
  end

  it "can update a post" do
    post = find_existing_post

    client.update_post(post.id, title: "Updated title")

    expect(client.find_post(post.id).title).to eq "Updated title"
  end

  it "raises errors if post could not be updated" do
    existing_post = find_existing_post

    expect {
      client.update_post(existing_post.id, status: "not really valid")
    }.to raise_error(Wpclient::ValidationError, /status/)

    expect {
      client.update_post(888888, title: "Never existed in the first place")
    }.to raise_error(Wpclient::NotFoundError)
  end

  it "correctly handles HTML" do
    post = client.create_post(
      title: "HTML test",
      content: '<p class="hello-world">Hello world</p>',
    )

    expect(post.content_html.strip).to eq '<p class="hello-world">Hello world</p>'

    expect(
      client.find_post(post.id).content_html.strip
    ).to eq '<p class="hello-world">Hello world</p>'
  end

  def find_existing_post
    posts = client.posts(per_page: 1)
    expect(posts).to_not be_empty
    posts.first
  end
end
