require "shellwords"
require "uri"

module DockerRunner
  def start_wordpress_server
    container_id, host, port = start_docker_container
    Server.new(container_id: container_id, port: port, host: host)
  end

  class Server
    attr_reader :container_id, :port, :host

    def initialize(container_id:, port:, host:)
      @container_id = container_id
      @port = port
      @host = host
    end

    def url
      "http://#{host}:#{port}/wp-json"
    end

    # Defined in the dbdump in spec/docker/dbdump.sql.gz
    def username() "test" end
    def password() "test" end
  end

  private
  def start_docker_container
    fail_if_docker_missing
    build_container_if_missing

    host = docker_host
    port = 8181

    container_id = start_container(port: port)

    print "Waiting for container to start..."

    begin
      wait_for_container_to_start(container_id, port: port, host: host)
    rescue
      kill_container container_id
      raise $!
    end

    puts " http://#{host}:#{port}"
    at_exit { kill_container container_id }
    [container_id, host, port]
  end

  def fail_if_docker_missing
    unless system("hash docker > /dev/null")
      STDERR.puts "It does not look like you have docker installed. Please install docker so you can run integration tests."
      fail "No docker installed"
    end
  end

  def build_container_if_missing
    unless system("docker images | grep -q '^wpclient-test '")
      system("cd spec/docker && docker build -t wpclient-test .")
    end
  end

  def start_container(port:)
    output = %x{docker run -dit -p #{port.to_i}:80 -e WORDPRESS_HOST="#{docker_host.shellescape}:#{port.to_i}" wpclient-test}
    if $?.success?
      output.chomp
    else
      fail "Failed to start container. Maybe it's already running? Output: #{output}"
    end
  end

  def kill_container(container_id)
    output = %x{
      docker kill #{container_id.shellescape};
      docker rm #{container_id.shellescape}
    }
    unless $?.success?
      raise "Could not clean up docker image #{container_id}. Output was:\n#{output}.\n"
    end
  end

  def wait_for_container_to_start(container_id, port:, host:)
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

  def docker_host
    if ENV['DOCKER_HOST']
      URI.parse(ENV['DOCKER_HOST']).host
    else
      "localhost"
    end
  end
end
