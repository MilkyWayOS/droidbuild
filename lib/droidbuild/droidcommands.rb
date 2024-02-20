require 'droidbuild'
require 'droidmodule'
require 'command'
require 'sync/repo'
require 'device/common'
require 'keys/crypto'

module Commands
  on_command "scan-modules" do
    if File.exist? ".droidmodules"
      File.delete ".droidmodules"
    end
    paths = find_and_load_modules
    File.open(".droidmodules", "w+") do |file|
      paths.each do |path|
        file.write(path + "\n")
      end
    end
  end

  on_command "sync" do
    Configuration.load_configuration
    synchronize_repo_and_tell_modules
  end

  on_command "build-device" do |argv|
    if argv.length == 0
      error "build-device needs exactly one argument"
      exit -1
    end
    if argv.length > 1
      error "Extra arguments on command line"
      exit -1
    end
    codename = argv[0]
    unless Devices.device_exists?(codename)
      error "Can not find device with #{codename}. Maybe you need to re-scan modules?"
      exit -1
    end
    Devices.build_device(codename)
  end

  on_command "generate-keys" do |argv|
    if argv.length > 0
      error "Extra arguments on command line"
      exit -1
    end
    Configuration.load_configuration
    generate_keys
  end
end