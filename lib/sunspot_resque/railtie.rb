require 'rails/railtie'

module SunspotResque
  class Railtie < Rails::Railtie
    initializer 'sunspot_resque.load_sunspot_session_proxy' do
      unless ENV['DISABLE_SUNSPOT_RESQUE']
        Sunspot.session = SessionProxy.new(Sunspot.session)
      end
    end
    rake_tasks do
      load File.expand_path('../tasks/sunspot.rake', __FILE__)
    end
  end
end