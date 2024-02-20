# frozen_string_literal: true
require 'meta'

def execute(cmdline)
  info "Execute: #{cmdline}"
  result = system "bash -c '#{cmdline}'"
  unless result
    error "Failed to execute command"
    exit -1
  end
end

def change_dir(new_dir)
  info "Entering directory: #{new_dir}"
  Dir.chdir(new_dir)
end

def exit_dir
  info "Exiting directory"
  Dir.chdir(BASEDIR)
end

GET_MY_DIR = "File.dirname(__FILE__)"