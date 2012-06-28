require 'rails/railtie'

module SunspotResque
  class Railtie < Rails::Railtie
    unless ENV['DISABLE_SUNSPOT_RESQUE']
      initializer 'sunspot_resque.load_sunspot_session_proxy' do
        Sunspot.session = SessionProxy.new(Sunspot.session)
      end
    end
    rake_tasks do
      load File.expand_path('../tasks/sunspot.rake', __FILE__)
    end
  end
end