# frozen_string_literal: true
require 'yaml'

class Comff
  def initialize(file_content = nil)
    @conf = nil

    load_conf_file!(file_content) if file_content
  end

  def get_bool(key, default=nil)
    raw_value = get_str(key)
    return default if raw_value == nil

    value = raw_value&.to_s&.downcase

    return true if value == "true"
    return false if value == "false"

    raise "Invalid value '#{raw_value}' for key #{key}"
  end

  def get_bool!(key)
    value = get_bool(key)
    raise "Config key #{key} is required" if value == nil

    value
  end

  def get_int(key, default=nil)
    value = get_str(key)
    return default if value == nil
    Integer(value)
  end

  def get_int!(key)
    value = get_int(key)
    raise "Config key #{key} is required" unless value
    Integer(value)
  end

  def get_str(key, default=nil)
    env_var_name = key_to_env_var_name(key)
    return ENV[env_var_name] if ENV.key?(env_var_name)

    parts = key.split('.')
    base_obj = if parts.length == 1
      @conf
    else
      @conf.dig(*parts[0...-1])
    end

    base_obj.fetch(parts.last, default)
  end

  def get_str!(key)
    none = Object.new
    value = get_str(key, none)
    raise "Config key #{key} is required" if value == none

    value
  end

  def self.load_global(file_content)
    @global = Comff.new(file_content)
  end

  def self.get_str!(*args); @global.get_str!(*args); end
  def self.get_str(*args); @global.get_str(*args); end
  def self.get_int!(*args); @global.get_int!(*args); end
  def self.get_int(*args); @global.get_int(*args); end
  def self.get_bool!(*args); @global.get_bool!(*args); end
  def self.get_bool(*args); @global.get_bool(*args); end

  private

  # Convert key format from foo.bar.qux
  # into FOO_BAR_QUX
  def key_to_env_var_name(key)
    key.split('.').map(&:upcase).join('_')
  end

  def load_conf_file!(file_content)
    @conf = YAML.safe_load(file_content)
  end
end
