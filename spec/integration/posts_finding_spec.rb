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

end
