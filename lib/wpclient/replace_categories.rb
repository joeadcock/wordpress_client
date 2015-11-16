require "set"

module Wpclient
  class ReplaceCategories
    def self.call(connection, post, category_ids)
      new(connection, post, category_ids).replace
    end

    def initialize(connection, post, category_ids)
      @connection = connection
      @post = post
      @wanted_ids = category_ids.to_set
      @existing_ids = post.category_ids.to_set
    end

    def replace
      categories_to_add.each { |id| add_category_id(id) }
      categories_to_remove.each { |id| remove_category_id(id) }
    end

    private
    attr_reader :connection, :post, :wanted_ids, :existing_ids

    def categories_to_add
      wanted_ids - existing_ids
    end

    def categories_to_remove
      existing_ids - wanted_ids
    end

    def add_category_id(id)
      connection.create_without_response("posts/#{post.id}/terms/category/#{id}", {})
    end

    def remove_category_id(id)
      connection.delete("posts/#{post.id}/terms/category/#{id}", force: true)
    end
  end
end
