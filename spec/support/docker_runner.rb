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
        #{name.shellescape} \
      2>&1
    `
    if $?.success?
      output.chomp
    else
      fail "Failed to start container. Maybe it's already running? Output:\n#{output}"
    end
  end

  def kill_container(id)
    output = `docker kill #{id.shellescape} 2>&1`
    raise_on_failure(
      action: "kill",
      id: id,
      exit_status: $?,
      output: output,
    )
  end

  def remove_container(id)
    output = `docker rm #{id.shellescape} 2>&1`
    raise_on_failure(
      action: "remove",
      id: id,
      exit_status: $?,
      output: output,
    )
  end

  private
  def raise_on_failure(action:, exit_status:, output:, id:)
    unless exit_status.success?
      message = "Could not #{action} docker image #{id}. Output was:\n#{output}.\n"
      raise message
    end
  end
end
