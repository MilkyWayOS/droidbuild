# frozen_string_literal: true
require 'command'
require 'droidlib'
require 'meta'
require 'config'

def build_docker
  unless File.exist?(".droidbuildx.yaml")
    error "Can not find config .droidbuildx.yaml"
    exit -1
  end
  execute "docker buildx build . -t #{DOCKER_TAG}"
end

def docker_shell
  buildroot = Configuration.get_value("storage.buildroot")
  ota = Configuration.get_value("storage.ota")
  execute "docker run -it \\
            -v #{ota}:/opt/droid/buildroot/out_dir \\
            -v #{buildroot}:/opt/droid/buildroot \\
           --entrypoint /bin/bash #{DOCKER_TAG}"
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
