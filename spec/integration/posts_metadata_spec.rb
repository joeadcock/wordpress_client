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

  it "can remove metadata for a post" do
    post = client.create_post(title: "Metadata creation", meta: {one: "1", two: "2", three: "3"})
    post = client.update_post(post.id, meta: {three: "3", two: nil})
    expect(post.meta).to eq("three" => "3")
  end
end
