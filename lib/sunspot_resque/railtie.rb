require 'rails/railtie'

module Sunspot::Resque
  class Railtie < Rails::Railtie
    initializer 'sunspot_resque.load_sunspot_session_proxy' do
      unless ENV['DISABLE_SUNSPOT_RESQUE'] == 'true'
        Sunspot.session = SessionProxy.new(Sunspot.session)
      end
    end
    rake_tasks do
      load File.expand_path('../tasks/disable_sunspot_resque.rake', __FILE__)
    end
  end
end