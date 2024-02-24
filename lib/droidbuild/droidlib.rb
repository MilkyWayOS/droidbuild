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

def require_file(path)
  unless File.exist? path
    error "Can not find required file #{path}"
    exit -1
  end
end

def list_to_arguments(list)
  result = ""
  list.each do |s|
    result += s
    result += ' '
  end
  result
end

GET_MY_DIR = "File.dirname(__FILE__)"