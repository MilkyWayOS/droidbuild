# frozen_string_literal: true
require 'log'
require 'command'

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
    :TARGET_FULL_NAME => "Generic device",
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

  def self.build_device(codename)
    @devices[codename].constants.each do |name, value|
      const_set(name, value)
    end
    Droidbuild.modules.each do |_, mod|
      mod.on_before_build(codename)
    end
  end
end

module Commands
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
end