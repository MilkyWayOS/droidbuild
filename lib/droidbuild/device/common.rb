# frozen_string_literal: true
require 'log'
require 'command'

module Device
  @devices = {}

  class <<self
    attr_reader :devices
  end

  def self.device_exists?(codename)

  end

  TARGET_ADDITIONAL_MANIFESTS = []
  TARGET_CODENAME = ""
  TARGET_FULLNAME = ""
  TARGET_BUILDTYPE = "eng"
  TARGET_SIGNED_BUILD = false
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
  end
end