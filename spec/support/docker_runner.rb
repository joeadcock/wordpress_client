require "shellwords"
require "uri"

module DockerRunner
  extend self

  def docker_installed?
    system("hash docker > /dev/null 2> /dev/null")
  end

  def image_exists?(name)
    name, tag = name.split(":", 2)
    matcher = "^#{name} "
    matcher << "[[:space:]]*#{tag}" if tag

    system("docker images | grep -q #{matcher.shellescape}")
  end

  def build_image(name, path: Dir.pwd)
    system("docker build -t #{name.shellescape} #{path.shellescape}")
  end

  def run_container(name, port:, environment: {})
    environment_flags = environment.map { |key, value|
      "-e #{key.to_s.upcase.shellescape}=#{value.shellescape}"
    }

    output = `
      docker run \
        -dit -p #{port.to_i}:80 \
        #{environment_flags.join(" ")} \
        #{name.shellescape}
    `
    if $?.success?
      output.chomp
    else
      fail "Failed to start container. Maybe it's already running? Output: #{output}"
    end
  end

  def purge_container(id)
    output = `docker kill #{id.shellescape}; docker rm #{id.shellescape} `

    unless $?.success?
      message = "Could not clean up docker image #{id}. Output was:\n#{output}.\n"
      if ENV["CIRCLECI"]
        puts message
      else
        raise message
      end
    end
  end
end
