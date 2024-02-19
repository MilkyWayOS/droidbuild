# frozen_string_literal: true
require 'log'
require 'droidmodule'
require 'command'

module Droidbuild
  define_module "example"
  on_load do
    info "Example module has been loaded"
  end
  end_module
end

module Commands
  on_command("example") do |args|
    info "Called example command with arguments #{args}"
  end
end
