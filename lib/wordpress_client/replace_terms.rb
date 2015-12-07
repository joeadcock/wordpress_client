require "set"

module WordpressClient
  class ReplaceTerms
    def self.apply_categories(connection, post, category_ids)
      instance = new(
        connection,
        post.id,
        post.category_ids,
        category_ids
      )
      instance.replace("category")
      instance.number_of_changes
    end

    def self.apply_tags(connection, post, tag_ids)
      instance = new(
        connection,
        post.id,
        post.tag_ids,
        tag_ids
      )
      instance.replace("tag")
      instance.number_of_changes
    end

    def initialize(connection, post_id, existing_ids, new_ids)
      @connection = connection
      @post_id = post_id
      @existing_ids = existing_ids.to_set
      @wanted_ids = new_ids.to_set
    end

    def replace(type)
      ids_to_add.each { |id| add_term_id(id, type) }
      ids_to_remove.each { |id| remove_term_id(id, type) }
    end

    def number_of_changes
      ids_to_add.size + ids_to_remove.size
    end

    private
    attr_reader :connection, :post_id, :wanted_ids, :existing_ids

    def ids_to_add
      wanted_ids - existing_ids
    end

    def ids_to_remove
      existing_ids - wanted_ids
    end

    def add_term_id(id, type)
      connection.create_without_response("posts/#{post_id}/terms/#{type}/#{id}", {})
    end

    def remove_term_id(id, type)
      connection.delete("posts/#{post_id}/terms/#{type}/#{id}", force: true)
    end
  end
end
