# -*- encoding: utf-8 -*-
require File.expand_path '../lib/sunspot_resque/version', __FILE__

Gem::Specification.new do |gem|
  gem.authors       = ['Sijawusz Pur Rahnama', 'Andrew Evans']
  gem.email         = ['sija@sija.pl']
  gem.summary       = 'Sunspot-Resque Session Proxy'
  gem.homepage      = 'https://github.com/Sija/sunspot_resque'
  gem.description   = %q(
  )

  gem.files         = `git ls-files`.split $\
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename f }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'sunspot_resque'
  gem.require_paths = ['lib']
  gem.version       = SunspotResque::VERSION

  gem.add_dependency 'rails', '~> 3'
  gem.add_dependency 'sunspot'
  gem.add_dependency 'sunspot_rails'
  gem.add_dependency 'resque', '>= 1.20.0'
end
