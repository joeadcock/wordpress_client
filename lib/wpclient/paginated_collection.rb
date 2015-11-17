module Wpclient
  class PaginatedCollection
    include Enumerable
    attr_reader :total, :current_page, :per_page

    def initialize(entries, total:, current_page:, per_page:)
      @entries = entries
      @total = total
      @current_page = current_page
      @per_page = per_page
    end

    def each
      if block_given?
        @entries.each { |e| yield e }
      else
        @entries.each
      end
    end

    def replace(new_list)
      @entries.replace(new_list)
    end

    #
    # Pagination methods. Fulfilling will_paginate protocol
    #

    alias total_entries total

    def total_pages
      if total.zero? || per_page.zero?
        0
      else
        (total / per_page.to_f).ceil
      end
    end

    def next_page
      if current_page < total_pages
        current_page + 1
      end
    end

    def previous_page
      if current_page > 1
        current_page - 1
      end
    end

    def out_of_bounds?
      current_page < 1 || current_page > total_pages
    end

    # will_paginate < 3.0 has this method
    def offset
      if current_page > 0
        (current_page - 1) * per_page
      else
        0
      end
    end

    #
    # Array-like behavior
    #

    def size
      @entries.size
    end

    def empty?
      @entries.empty?
    end

    def to_a
      @entries
    end

    def [](*args)
      @entries[*args]
    end

    def first
      @entries.first
    end

    def last
      @entries.last
    end

    # Allow PaginatedCollection to be coerced into an array
    alias to_ary to_a
  end
end
