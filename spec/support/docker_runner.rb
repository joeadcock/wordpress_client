require "shellwords"
require "uri"

module DockerRunner
  def start_wordpress_server
    WebMock.allow_net_connect!
    print "Waiting for container to start..."
    Server.new(host: docker_host, port: 8181).tap do |server|
      puts " http://#{server.host}:#{server.port}"
    end
  end

  private
  def docker_host
    if ENV['DOCKER_HOST']
      URI.parse(ENV['DOCKER_HOST']).host
    else
      "localhost"
    end
  end

  class Server
    attr_reader :container_id, :port, :host

    def initialize(host:, port:)
      @host = host
      @port = port

      start_docker_container
    end

    def stop
      kill_container
    end

    def url
      "http://#{host}:#{port}/wp-json"
    end

    # Defined in the dbdump in spec/docker/dbdump.sql.gz
    def username() "test" end

    # Defined in the dbdump in spec/docker/dbdump.sql.gz
    def password() "test" end

    private
    def start_docker_container
      fail_if_docker_missing
      build_container_if_missing

      @container_id = start_container

      begin
        wait_for_container_to_start
        at_exit { kill_container }
      rescue
        kill_container
        raise $!
      end
    end

    def fail_if_docker_missing
      unless system("hash docker > /dev/null 2> /dev/null")
        STDERR.puts(
          "It does not look like you have docker installed. " \
          "Please install docker so you can run integration tests."
        )
        fail "No docker installed"
      end
    end

    def build_container_if_missing
      unless system("docker images | grep -q '^wpclient-test '")
        system("cd spec/docker && docker build -t wpclient-test .")
      end
    end

    def start_container
      output = `
        docker run \
          -dit -p #{port.to_i}:80 \
          -e WORDPRESS_HOST="#{host.shellescape}:#{port.to_i}" \
          wpclient-test
      `
      if $?.success?
        output.chomp
      else
        fail "Failed to start container. Maybe it's already running? Output: #{output}"
      end
    end

    def kill_container
      return if @stopped

      output = `
        docker kill #{container_id.shellescape};
        docker rm #{container_id.shellescape}
      `

      unless $?.success?
        message = "Could not clean up docker image #{container_id}. Output was:\n#{output}.\n"
        if ENV["CIRCLECI"]
          puts message
        else
          raise message
        end
      end

      @stopped = true
    end

    def wait_for_container_to_start
      # Try to connect to the webserver in a loop until we successfully connect,
      # the container process dies, or the timeout is reached.
      timeout = 60
      start = Time.now

      loop do
        fail "Timed out while waiting for the container to start" if Time.now - start > timeout

        begin
          response = Faraday.get("http://#{host}:#{port}/")
          return if response.status == 200
        rescue Faraday::ConnectionFailed
          # Server not yet started. Just wait it out...
        end
        sleep 0.5
      end
    end
  end
end
