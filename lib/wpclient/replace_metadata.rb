require "set"

module Wpclient
  class ReplaceMetadata
    def self.call(connection, post, meta)
      new(connection, post, meta).call
    end

    def initialize(connection, post, meta)
      @connection = connection
      @post = post
      @existing_meta = post.meta
      @new_meta = stringify_keys(meta)
    end

    def call
      all_keys.each do |key|
        action = determine_action(key)
        send(action, key, new_meta[key])
      end
    end

    private
    attr_reader :connection, :post, :new_meta, :existing_meta

    def meta_id(key)
      post.meta_id_for(key)
    end

    def all_keys
      (new_meta.keys + existing_meta.keys).to_set
    end

    def determine_action(key)
      old_value = existing_meta[key]
      new_value = new_meta[key]

      if old_value.nil? && !new_value.nil?
        :add
      elsif old_value == new_value
        :keep
      elsif new_value.nil?
        :remove
      else
        :replace
      end
    end

    def add(key, value)
      connection.create_without_response("posts/#{post.id}/meta", key: key, value: value)
    end

    def remove(key, *)
      connection.delete("posts/#{post.id}/meta/#{meta_id(key)}", force: true)
    end

    def replace(key, value)
      connection.patch_without_response(
        "posts/#{post.id}/meta/#{meta_id(key)}", key: key, value: value
      )
    end

    def keep(*)
      # Do nothing. This method is here to satisfy every action of #determine_action.
    end

    def stringify_keys(hash)
      hash.each_with_object({}) do |(key, value), new_hash|
        new_hash[key.to_s] = value
      end
    end
  end
end
