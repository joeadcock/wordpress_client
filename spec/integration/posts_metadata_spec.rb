require "spec_helper"

describe "Post meta" do
  setup_integration_client

  it "can be set on a post" do
    post = client.create_post(title: "Metadata creation", meta: {foo: "bar"})
    expect(post.meta).to eq("foo" => "bar")
  end

  it "can be updated on a post" do
    post = client.create_post(title: "Metadata creation", meta: {before: "now"})
    post = client.update_post(post.id, meta: {"before" => "then", "after" => "now"})
    expect(post.meta).to eq("before" => "then", "after" => "now")
  end
end
