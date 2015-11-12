require "set"

module Wpclient
  class ReplaceMetadata
    def self.call(client, post, meta)
      new(client, post, meta).call
    end

    def initialize(client, post, meta)
      @client = client
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
    attr_reader :client, :post, :new_meta, :existing_meta

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
      client.assign_meta_to_post(post_id: post.id, key: key, value: value)
    end

    def remove(key, *)
      client.remove_meta_from_post(post_id: post.id, meta_id: post.meta_id_for(key))
    end

    def replace(key, value)
      remove(key)
      add(key, value)
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
