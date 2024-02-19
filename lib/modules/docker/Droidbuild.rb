# frozen_string_literal: true
require 'command'
require 'droidlib'
require 'meta'
require 'config'

def build_docker
  execute "docker buildx build . -t #{DOCKER_TAG}"
end

def docker_shell
  buildroot = Configuration.get_value("storage.buildroot")
  s
  execute "docker run -it --entrypoint /bin/bash #{DOCKER_TAG}"
end

module Commands
  on_command "docker-build" do |argv|
    if argv.length > 0
      error "Extra arguments on command line"
      exit -1
    end
    build_docker
  end

  on_command "docker-shell" do |argv|
    if argv.length > 0
      error "Extra arguments on command line"
      exit -1
    end
    build_docker
    docker_shell
  end
end
