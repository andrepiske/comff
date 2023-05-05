require 'comff'

class ComffRailtie < Rails::Railtie
  def load
    load_comffig
  end

  def overload
    load_comffig
  end

  def self.load
    instance.load
  end

  private

  def load_comffig
    Comff.load_global(File.read(File.join(Rails.root, "config/conf.#{Rails.env}.yml")))
  end

  config.before_configuration { load }
end
