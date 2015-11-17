module Wpclient
  class Term
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
      if other.is_a? Term
        other.class == self.class &&
          other.id == id &&
          other.name == name &&
          other.slug == slug
      else
        super
      end
    end

    def inspect
      "#<#{self.class} ##{id} #{name.inspect} (#{slug})>"
    end
  end
end
