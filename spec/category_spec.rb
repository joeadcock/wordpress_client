require "spec_helper"

describe Wpclient::Category do
  def create(id: 1, name: "Name", slug: "slug")
    Wpclient::Category.new(id: id, name: name, slug: slug)
  end

  it "is equal to another instance with the same attributes" do
    expect(create(id: 5)).to_not eq create(id: 4)
    expect(create(name: "Foo")).to_not eq create(name: "Bar")
    expect(create(slug: "foo")).to_not eq create(slug: "bar")

    expect(create).to eq create
  end
end
