module Wpclient
  class ReplaceMetadata
    def self.call(client, post, meta)
      new(client, post, meta).replace
    end

    def initialize(client, post, meta)
      @client = client
      @post = post
      @existing_meta = post.meta
      @meta = stringify_keys(meta)
    end

    def replace
      each_changed_meta do |key, value|
        client.assign_meta_to_post(post_id: post.id, key: key, value: value)
      end

      each_extra_meta do |key|
        client.remove_meta_from_post(post_id: post.id, meta_id: post.meta_id_for(key))
      end
    end

    private
    attr_reader :client, :post, :meta, :existing_meta

    def each_changed_meta
      meta.each_pair do |key, value|
        next if existing_meta[key.to_s] == value
        yield key.to_s, value
      end
    end

    def each_extra_meta
      existing_meta.each_key do |key|
        next if meta.has_key?(key)
        yield key
      end
    end

    def stringify_keys(hash)
      hash.each_with_object({}) do |(key, value), new_hash|
        new_hash[key.to_s] = value
      end
    end
  end
end
