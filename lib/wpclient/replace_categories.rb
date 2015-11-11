require "set"

module Wpclient
  class ReplaceCategories
    def self.call(client, post, category_ids)
      new(client, post, category_ids).replace
    end

    def initialize(client, post, category_ids)
      @client = client
      @post = post
      @wanted_ids = category_ids.to_set
      @existing_ids = post.category_ids.to_set
    end

    def replace
      categories_to_add.each do |id|
        client.assign_category_to_post(post_id: post.id, category_id: id)
      end

      categories_to_remove.each do |id|
        client.remove_category_from_post(post_id: post.id, category_id: id)
      end
    end

    private
    attr_reader :client, :post, :wanted_ids, :existing_ids

    def categories_to_add
      wanted_ids - existing_ids
    end

    def categories_to_remove
      existing_ids - wanted_ids
    end
  end
end
