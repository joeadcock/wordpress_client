module Wpclient
  class Term
    attr_reader :id, :name_html, :slug

    def self.parse(data)
      new(
        id: data.fetch("id"),
        name_html: data.fetch("name"),
        slug: data.fetch("slug"),
      )
    end

    def initialize(id:, name_html:, slug:)
      @id = id
      @name_html = name_html
      @slug = slug
    end

    def ==(other)
      if other.is_a? Term
        other.class == self.class &&
          other.id == id &&
          other.name_html == name_html &&
          other.slug == slug
      else
        super
      end
    end

    def inspect
      "#<#{self.class} ##{id} #{name_html.inspect} (#{slug})>"
    end
  end
end
