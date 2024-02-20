# frozen_string_literal: true
require 'droidmodule'
require 'droidcommands'
require 'command'

def find_and_load_modules
  modules_path_list = []
  info "Scanning modules"
  Dir.glob("**/Droidbuild.rb").each do |fname|
    info "Including #{fname}"
    modules_path_list << fname
    require fname
  end
  Droidbuild.modules.each do |_, mod|
    mod.on_load
  end
  modules_path_list
end

def load_modules
  if File.exist? ".droidmodules"
    File.readlines(".droidmodules").each do |line|
      fname = line.strip
      info "Including #{fname}"
      require fname
    end
  else
    paths = find_and_load_modules
    File.open(".droidmodules", "w+") do |file|
      paths.each do |path|
        file.write(path + "\n")
      end
    end
    info "Written modules list. If you would like to manually re-scan modules please use `droidbuild scan-modules`"
  end
end

def print_usage(argv)
  print("Usage: droidbuildx SUB-COMMAND [OPTIONS...]\n")
end

def main(argv)
  if argv.length < 1
    print_usage argv
    exit -1
  end
  load_modules
  Commands.call_command(argv[0], argv[1..])
  0
end