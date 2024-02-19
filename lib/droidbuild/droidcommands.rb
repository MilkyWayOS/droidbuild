require 'droidbuild'
require 'droidmodule'
require 'command'
require 'sync/repo'

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
end