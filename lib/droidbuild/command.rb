# frozen_string_literal: true
require 'log'

class Command
  attr_writer :on_call_lambda
  def initialize(name)
    super()
    @name = name
    @on_call_lambda = -> (_) {}
  end

  def on_call(args)
    @on_call_lambda.call(args)
  end
end

module Commands
  @commands_hash = Hash.new

  def self.on_command(name, &block)
    if @commands_hash.has_key? name
      error "Command #{name} is already registered"
      exit -1
    end
    command = Command.new(name)
    command.on_call_lambda = block
    @commands_hash[name] = command
  end

  def self.call_command(name, argv)
    if @commands_hash.has_key? name
      @commands_hash[name].on_call(argv)
    else
      error "Unknown command #{name}. Maybe you need to re-scan modules?"
      exit -1
    end
  end
end