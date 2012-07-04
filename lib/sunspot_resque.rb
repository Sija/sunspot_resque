require 'sunspot_resque/version'
require 'sunspot_resque/railtie'

module Sunspot
  module Resque
    autoload :SessionProxy, 'sunspot_resque/sunspot/session_proxy'
    autoload :Worker, 'sunspot_resque/resque/worker'
  end
  
  def self.without_proxy
    proxy = if Sunspot.session.is_a? Resque::SessionProxy
      Sunspot.session
    end
    Sunspot.session = proxy.original_session if proxy

    yield
  ensure
    Sunspot.session = proxy if proxy
  end
end
