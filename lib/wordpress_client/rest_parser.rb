module WordpressClient
  module RestParser
    private
    def rendered(name)
      (data[name] || {})["rendered"]
    end

    def read_date(name)
      # Try to read UTC time first
      if (gmt_time = data["#{name}_gmt"])
        Time.iso8601("#{gmt_time}Z")
      elsif (local_time = data[name])
        Time.iso8601(local_time)
      end
    end
  end
end
