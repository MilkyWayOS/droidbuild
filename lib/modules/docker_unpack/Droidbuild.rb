# frozen_string_literal: true
require 'log'
require 'droidlib'

module Commands
  on_command("docker-unpack") do |argv|
    if argv.length > 0
      error "Extra arguments on command line"
      exit -1
    end
    unless Dir.exist?("/opt/droid")
      error "Can not find /opt/droid. Are you running in docker?"
      exit -1
    end
    info "Calling unpack utility directly"
    execute "droidbuildx-unpack"
    success "Unpacked droidbuildx to buildroot"
  end
end
