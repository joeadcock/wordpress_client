require_relative "docker_runner"

class WordpressServer
  include Singleton

  attr_reader :container_id, :port, :host

  def initialize
    @host = docker_host
    @port = 8181

    start_docker_container
    at_exit { purge_container }
  end

  def url
    "http://#{host_with_port}/wp-json"
  end

  # Defined in the dbdump in spec/docker/dbdump.sql.gz
  def username() "test" end

  # Defined in the dbdump in spec/docker/dbdump.sql.gz
  def password() "test" end

  private
  def host_with_port
    "#{host}:#{port}"
  end

  def docker_host
    if ENV['DOCKER_HOST']
      URI.parse(ENV['DOCKER_HOST']).host
    else
      "localhost"
    end
  end

  def start_docker_container
    fail_if_docker_missing
    build_container_if_missing

    @container_id = start_container
    @running = true

    begin
      wait_for_container_to_start
    rescue
      purge_container
      raise $!
    end
  end

  def fail_if_docker_missing
    unless DockerRunner.docker_installed?
      STDERR.puts(
        "It does not look like you have docker installed. " \
        "Please install docker so you can run integration tests."
      )
      fail "No docker installed"
    end
  end

  def build_container_if_missing
    unless DockerRunner.image_exists?("wpclient-test")
      DockerRunner.build_image("wpclient-test", path: "spec/docker")
    end
  end

  def start_container
    DockerRunner.run_container(
      "wpclient-test",
      port: port,
      environment: {wordpress_host: host_with_port}
    )
  end

  def purge_container
    if @running
      DockerRunner.purge_container(container_id)
      @running = true
    end
  end

  def wait_for_container_to_start
    # Try to connect to the webserver in a loop until we successfully connect,
    # the container process dies, or the timeout is reached.
    timeout = 60
    start = Time.now

    loop do
      fail "Timed out while waiting for the container to start" if Time.now - start > timeout

      begin
        response = Faraday.get(url)
        return if response.status == 200
      rescue Faraday::ConnectionFailed
        # Server not yet started. Just wait it out...
      end
      sleep 0.5
    end
  end
end
