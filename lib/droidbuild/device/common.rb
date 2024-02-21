# frozen_string_literal: true
require 'log'
require 'command'
require 'config'
require 'meta'
require 'sync/repo'
require 'keys/crypto'

class Device
  attr_reader :constants
  def initialize(constants)
    super()
    @constants = constants
    constants.each do |const,value|
      define_singleton_method(const) do
        @constants[value]
      end
    end
  end
end

module Devices
  @devices = {}
  @device = nil
  @current_device = nil
  @constant_defaults = {
    :TARGET_BUILD_TYPE => 'eng',
    :TARGET_LOCAL_MANIFESTS => [],
    :TARGET_FULL_NAME => 'Generic device',
    :TARGET_SIGNED_BUILD => false,
  }

  class <<self
    attr_reader :devices
    attr_accessor :device
  end

  def self.device_exists?(codename)
    @devices.has_key? codename
  end

  def self.define_device(codename)
    if device_exists? codename
      error "Device with codename #{codename} already defined"
      exit -1
    end
    @current_device = codename
  end

  def self.end_device
    @constant_defaults.each do |key, value|
      const_set(key, value) unless const_defined?(key)
    end
    device_constants = {}
    constants.each do |name|
      value = const_get(name)
      device_constants[name] = value
      remove_const(name)
    end
    @devices[@current_device] = Device.new(device_constants)
  end

  def self.add_constant_default(key, value)
    if @constant_defaults.has_key?(key)
      error "Attempted to add constant #{key} twice"
      exit -1
    end
    @constant_defaults[key] = value
  end

  def self.do_sync_if_needed
    if TARGET_LOCAL_MANIFESTS.length > 0
      info "Copying local manifests for target"
      TARGET_LOCAL_MANIFESTS.each do |path|
        execute "cp #{path} #{BASEDIR}/.repo/local_manifests/"
      end
      synchronize_repo_and_tell_modules
    end
  end

  def self.get_ota_meta_string(codename, keys="release-keys")
    datetime=`date '+%Y%m%d_%H%M%S'`
    "#{codename}-#{datetime}-#{TARGET_BUILD_TYPE}.#{keys}"
  end

  def self.prepare_signing
    info "Preparing signing environment"
    execute "rm -rf build/make/tools/framework"
    execute "rm -rf build/make/tools/lib64"
    execute "rm -rf build/make/tools/bin"
    execute "cp -r out/host/linux-x86/framework build/make/tools/framework"
    execute "cp -r out/host/linux-x86/lib64 build/make/tools/lib64"
    execute "cp -r out/host/linux-x86/bin build/make/tools/bin"
    success "Signing environment ready"
  end

  def self.do_build_signed(codename)
    nproc = Configuration.get_value("build.nproc", `nproc`)
    do_sync_if_needed
    matching_files = Dir.glob("*#{codename}*-signed-target-files*.zip")
    last_target_files = matching_files.sort.last
    const_set :TARGET_META_STRING, get_ota_meta_string(codename)
    open_keys
    info "Starting build"
    execute ". build/envsetup.sh; lunch lineage_#{codename}-#{TARGET_BUILD_TYPE}; mka target-files-package otatools -j#{nproc}"
    success "Built target files package succesfully"
    prepare_signing
    target_name = "#{MODIFICATION_NAME}-#{TARGET_META_STRING}"
    execute "sign_target_files_apks -o -d #{OPEN_KEYS_DIR}/android-certs #{BASEDIR}/out/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip #{OUT_DIR}/#{target_name}-signed-target_files.zip"
    success "Signed files succesfully"
    info "Building full OTA"
    execute "ota_from_target_files --skip_compatibility_check -v -k #{OPEN_KEYS_DIR}/android-certs/releasekey --block #{OUT_DIR}/#{target_name}-signed-target_files.zip #{OUT_DIR}/#{target_name}-OTA-signed.zip"
    success "Successfully built full OTA"
    full_ota_path = "#{OUT_DIR}/#{target_name}-OTA-signed.zip"
    incremental_ota_path = nil
    unless last_target_files.nil?
      info "Building incremental OTA"
      exec "ota_from_target_files --skip_compatibility_check -v -k #{OPEN_KEYS_DIR}/android-certs/releasekey --block -i #{last_target_files} #{OUT_DIR}/#{target_name}-signed-target_files.zip #{OUT_DIR}/#{target_name}-INCREMENTAL-OTA-signed.zip"
      incremental_ota_path = "#{OUT_DIR}/#{target_name}-INCREMENTAL-OTA-signed.zip"
    end
    Droidbuild.modules.each do |_, mod|
      mod.on_after_build(codename, full_ota_path, incremental_ota_path)
    end
  end

  def self.do_build_unsigned(codename)
    nproc = Configuration.get_value("build.nproc", `nproc`)
    do_sync_if_needed
    info "Starting build"
    execute ". build/envsetup.sh; lunch lineage_#{codename}-#{TARGET_BUILD_TYPE}; mka bacon -j#{nproc}"
    success "Built unsigned OTA package succesfully"
    Droidbuild.modules.each do |_, mod|
      mod.on_after_build(codename, nil, nil)
    end
  end

  def self.build_device(codename)
    @devices[codename].constants.each do |name, value|
      const_set(name, value)
    end
    Droidbuild.modules.each do |_, mod|
      mod.on_before_build(codename)
    end
    if TARGET_SIGNED_BUILD
      do_build_signed(codename)
    else
      do_build_unsigned(codename)
    end
  end
end