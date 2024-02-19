# frozen_string_literal: true
require 'config'
require 'droidlib'
require 'droidbuild'

def synchronize_repo
  info "Synchronizing repos"
  git_username = Configuration.get_value("sync.git_username")
  git_email = Configuration.get_value("sync.git_email")
  nproc = Configuration.get_value("common.nproc", `nproc`)
  base_repo = Configuration.get_value("sync.base_repo")
  base_repo_branch = Configuration.get_value("sync.base_repo_branch")
  execute "git config --global user.email '#{git_email}'"
  execute "git config --global user.name '#{git_username}'"
  execute "repo init --depth=1 -u #{base_repo} -b #{base_repo_branch} --git-lfs"
  execute "repo sync --current-branch --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune -j #{nproc}"
  success "Synchronization successful"
end

def synchronize_repo_and_tell_modules
  Droidbuild.modules.each do |_, mod|
    mod.on_before_sync
  end
  synchronize_repo
  if File.exist? ".droidmodules"
    File.delete ".droidmodules"
  end
  paths = find_and_load_modules
  File.open(".droidmodules", "w+") do |file|
    paths.each do |path|
      file.write(path + "\n")
    end
  end
  Droidbuild.modules.each do |_, mod|
    mod.on_after_sync
  end
end