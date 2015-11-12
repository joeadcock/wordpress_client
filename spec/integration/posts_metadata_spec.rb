require "spec_helper"

describe "Posts (metadata)" do
  setup_integration_client

  it "can be set on a post" do
    post = client.create_post(title: "Metadata creation", meta: {foo: "bar"})
    expect(post.meta).to eq("foo" => "bar")
  end
end
