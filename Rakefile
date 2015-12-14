require "bundler/gem_tasks"
require "yard"
require "wordpress_client/version"

YARD::Rake::YardocTask.new

namespace :docker do
  DOCKER_DIR = File.expand_path("../spec/docker", __FILE__).freeze
  IMAGE_NAME = "hemnet/wordpress_client_test".freeze
  DEV_IMAGE = [IMAGE_NAME, "dev"].join(":").freeze

  desc "Build the docker image"
  task :build do
    sh "docker", "build", "-t", DEV_IMAGE, DOCKER_DIR
  end

  desc "Release current dev build"
  task release: :build do
    version = prompt "Which version do you want to release"
    raise "Invalid version string" unless version =~ /\A[\d.]+\z/

    latest = prompt "Do you want this to be the :latest release? [Y/n]"
    latest = (latest.empty? || latest.downcase == "y")

    sh "docker", "tag", DEV_IMAGE, "#{IMAGE_NAME}:#{version}"
    sh "docker", "tag", "-f", DEV_IMAGE, "#{IMAGE_NAME}:latest" if latest

    sh "docker", "push", "#{IMAGE_NAME}:#{version}"
    sh "docker", "push", "#{IMAGE_NAME}:latest" if latest
  end
end

def prompt(message)
  print "#{message} > "
  STDIN.gets.strip
end
