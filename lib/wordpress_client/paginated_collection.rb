require "delegate"

module WordpressClient
  # Represents a paginated list of resources.
  #
  # @note This class has the full +Array+ interface by using
  #       +DelegateClass(Array)+. Methods do not show up in the documentation
  #       unless when manually documented.
  class PaginatedCollection < DelegateClass(Array)
    # @!method size
    #   @return [Fixnum] the number of records actually in this "page".
    #   @see Array#size

    attr_reader :total, :current_page, :per_page

    # @!attribute [r] total
    #   @return [Fixnum] the total hits in the full collection.
    #   @see #size #size is the size of the current "page".

    # @!attribute [r] current_page
    #   @return [Fixnum] the current page number, where +1+ is the first page.

    # @!attribute [r] per_page
    #   @return [Fixnum] the current page size setting, for example +30+.

    # Create a new collection using the passed array +entries+.
    #
    # @param entries [Array] the original "page" array
    def initialize(entries, total:, current_page:, per_page:)
      super(entries)
      @total = total
      @current_page = current_page
      @per_page = per_page
    end

    # @!group will_paginate protocol

    alias total_entries total

    # @note This method is used by +will_paginate+. By implementing this
    #       interface, you can use a {PaginatedCollection} in place of a
    #       +WillPaginate::Collection+ to render pagination details.
    # @return [Fixnum] the total number of pages that can show the {#total}
    #         entries with {#per_page} records per page. +0+ if no entries.
    def total_pages
      if total.zero? || per_page.zero?
        0
      else
        (total / per_page.to_f).ceil
      end
    end

    # @note This method is used by +will_paginate+. By implementing this
    #       interface, you can use a {PaginatedCollection} in place of a
    #       +WillPaginate::Collection+ to render pagination details.
    # @return [Fixnum, nil] the next page number or +nil+ if on last page.
    def next_page
      if current_page < total_pages
        current_page + 1
      end
    end

    # @note This method is used by +will_paginate+. By implementing this
    #       interface, you can use a {PaginatedCollection} in place of a
    #       +WillPaginate::Collection+ to render pagination details.
    # @return [Fixnum, nil] the previous page number or +nil+ if on first page.
    def previous_page
      if current_page > 1
        current_page - 1
      end
    end

    # @note This method is used by +will_paginate+. By implementing this
    #       interface, you can use a {PaginatedCollection} in place of a
    #       +WillPaginate::Collection+ to render pagination details.
    # @return [Boolean] if the current page is out of bounds, e.g. less than 1
    #                   or higher than {#total_pages}.
    def out_of_bounds?
      current_page < 1 || current_page > total_pages
    end

    # @note This method is used by +will_paginate+. By implementing this
    #       interface, you can use a {PaginatedCollection} in place of a
    #       +WillPaginate::Collection+ to render pagination details.
    #
    # @note will_paginate < 3.0 has this method, but it's no longer present in
    #       newer will_paginate.
    #
    # Returns the offset of the current page.
    #
    # @example First page offset
    #   collection.per_page # => 20
    #   collection.current_page # => 1
    #   collection.offset #=> 0
    # @example Later offset
    #   collection.per_page # => 20
    #   collection.current_page # => 3
    #   collection.offset #=> 40
    #
    def offset
      if current_page > 0
        (current_page - 1) * per_page
      else
        0
      end
    end

    # @!endgroup
  end
end
