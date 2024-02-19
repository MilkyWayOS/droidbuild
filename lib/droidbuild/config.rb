# frozen_string_literal: true
require 'yaml'
require 'log'

module Configuration
  @configuration = nil

  def self.load_configuration
    return unless @configuration.nil?
    unless File.exist? ".droidbuildx.yaml"
      error "Can not find .droidbuildx.yaml file"
      exit -1
    end
    @configuration = YAML.load_file(".droidbuildx.yaml")
    info "Loaded configuration"
  end

  def self.get_value(path_str, default=nil)
    self.load_configuration if @configuration.nil?
    path = path_str.split(".")
    current_config = @configuration
    path.each do |token|
      unless current_config.has_key? token
        if default.nil?
          error "Can not get #{path_str} from configuration"
          exit -1
        else
          return default
        end
      end
      current_config = current_config[token]
    end
    current_config
  end
end
