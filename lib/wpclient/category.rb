module Wpclient
  class Category
    attr_reader :id, :name, :slug

    def self.parse(data)
      new(
        id: data.fetch("id"),
        name: data.fetch("name"),
        slug: data.fetch("slug"),
      )
    end

    def initialize(id:, name:, slug:)
      @id = id
      @name = name
      @slug = slug
    end

    def ==(other)
      if other.kind_of? Category
        other.id == id &&
          other.name == name &&
          other.slug == slug
      else
        super
      end
    end
  end
end
