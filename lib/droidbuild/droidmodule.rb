# frozen_string_literal: true
require 'log'

class DroidbuildModule
  attr_writer :on_load_lambda,
              :on_call_lambda,
              :on_initial_setup_lambda,
              :on_before_sync_lambda,
              :on_after_sync_lambda,
              :on_before_build_lambda,
              :on_after_build_lambda
  def initialize(name)
    super()
    @name = name
    @on_load_lambda = lambda {}
    @on_call_lambda = lambda {}
    @on_initial_setup_lambda = lambda {}
    @on_before_sync_lambda = lambda {}
    @on_after_sync_lambda = lambda {}
    @on_before_build_lambda = -> (_) {}
    @on_after_build_lambda = -> (_, _, _) {}
  end


  def on_load
    @on_load_lambda.call
  end

  def on_call
    @on_call_lambda.call
  end

  def on_initial_setup
    @on_initial_setup_lambda.call
  end

  def on_before_sync
    @on_before_sync_lambda.call
  end

  def on_after_sync
    @on_after_sync_lambda.call
  end

  def on_before_build(device)
    @on_before_build_lambda.call(device)
  end

  def on_after_build(device, full_ota_fname, incremental_ota_fname)
    @on_after_build_lambda.call(device, full_ota_fname, incremental_ota_fname)
  end
end

module Droidbuild
  @modules = {}
  @current_module_name = nil
  @current_module = nil

  class <<self
    attr_reader :modules
  end

  def self._assert_current_module
    if @current_module.nil?
      error "Current module is not defined"
      exit -1
    end
  end

  def self.define_module(module_name)
    unless @current_module.nil?
      error "Defining module inside of the module. Have you forgot end_module in previous-loaded module?"
      exit -1
    end
    @current_module = DroidbuildModule.new(module_name)
    @current_module_name = module_name
    if @modules.has_key? module_name
      error "Module #{module_name} is duplicated!"
      exit -1
    end
    @modules[module_name] = @current_module
  end

  def self.on_load(&block)
    self._assert_current_module
    @current_module.on_load_lambda = block
  end

  def self.on_call(&block)
    self._assert_current_module
    @current_module.on_call_lambda = block
  end

  def self.on_initial_setup(&block)
    self._assert_current_module
    @current_module.on_initial_setup_lambda = block
  end

  def self.on_before_sync(&block)
    self._assert_current_module
    @current_module.on_before_sync_lambda = block
  end

  def self.on_after_sync(&block)
    self._assert_current_module
    @current_module.on_after_sync_lambda = block
  end

  def self.on_before_build(&block)
    self._assert_current_module
    @current_module.on_before_sync_lambda = block
  end

  def self.on_after_build(&block)
    self._assert_current_module
    @current_module.on_after_sync_lambda = block
  end

  def self.end_module
    self._assert_current_module
    @current_module = nil
    @current_module_name = nil
  end

end



