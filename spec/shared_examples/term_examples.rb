shared_examples_for(Wpclient::Term) do |fixture_name:|
  it "has an id, name and slug" do
    term = described_class.new(id: 5, name: "Heyho", slug: "heyho")
    expect(term.id).to eq 5
    expect(term.name).to eq "Heyho"
    expect(term.slug).to eq "heyho"
  end

  it "can be parsed" do
    term = described_class.parse(json_fixture(fixture_name))
    expect(term.id).to be_kind_of Integer

    expect(term.name).to be_kind_of String
    expect(term.slug).to be_kind_of String
    expect(term.name).to_not be_empty
    expect(term.slug).to_not be_empty
  end

  it "is equal to other instances with the same id, name and slug" do
    instance = described_class.new(id: 1, name: "One", slug: "one")
    copy     = described_class.new(id: 1, name: "One", slug: "one")

    expect(instance).to eq instance
    expect(instance).to eq copy

    expect(instance).to_not eq described_class.new(id: 2, name: "One", slug: "one")
    expect(instance).to_not eq described_class.new(id: 1, name: "Two", slug: "one")
    expect(instance).to_not eq described_class.new(id: 1, name: "One", slug: "two")
  end

  it "it not equal on other Term subclasses with the same id, name and slug" do
    other_subclass = Class.new(Wpclient::Tag)

    term = described_class.new(id: 1, name: "One", slug: "one")
    expect(term).to_not eq other_subclass.new(id: 1, name: "One", slug: "one")
  end
end
