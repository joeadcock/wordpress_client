require "spec_helper"

describe "Post meta" do
  setup_integration_client

  it "can be set on a post" do
    post = client.create_post(title: "Metadata creation", meta: {"foo" => 7})
    expect(post.meta).to include("foo" => 7)
  end

  it "can be updated on a post" do
    post = client.create_post(title: "Metadata creation", meta: {"foo" => 1})
    post = client.update_post(post.id, meta: {"foo" => 2, "bar" => true})
    expect(post.meta).to include("foo" => 2, "bar" => true)
  end

  it "can remove metadata for a post" do
    post = client.create_post(title: "Metadata creation", meta: {foo: 1, bar: true, baz: "foobar"})
    post = client.update_post(post.id, meta: {foo: 5, baz: nil})
    expect(post.meta).to eq("foo" => 5, "bar" => true, "baz" => "")
  end

  it "returns unescaped HTML" do
    post = client.create_post(title: "Metadata HTML", meta: {baz: "larry&curly<moe>"})
    expect(post.meta).to eq("baz" => "larry&curly<moe>", "foo" => 0, "bar" => false)
  end
end
