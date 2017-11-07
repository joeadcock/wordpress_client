module WordpressClient
  # @abstract Implement a subclass for the resource type.
  #
  # Implementation for the abstract "term" in Wordpress.
  #
  # @see Category
  # @see Tag
  class Term
    attr_reader :id, :name_html, :slug

    # @!attribute [r] id
    #   @return [Fixnum] The ID of the resource in Wordpress.

    # @!attribute [r] name_html
    #   @return [String] The name of the resource, HTML encoded.
    #   @example
    #     term.name_html #=> "Father &#038; Daughter stuff"

    # @!attribute [r] slug
    #   @return [String] The slug of the resource in Wordpress.

    # @api private
    #
    # Parses a data structure from a WP API response body into this term type.
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

    # @api private
    # Compares another instance. All attributes in this list must be equal for
    # the instances to be equal:
    #
    # * +id+
    # * +name_html+
    # * +slug+
    #
    # One must also not be a subclass of the other; they must be the exact same class.
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

    # Shows a nice representation of the term type.
    def inspect
      "#<#{self.class} ##{id} #{name_html.inspect} (#{slug})>"
    end
  end
end
