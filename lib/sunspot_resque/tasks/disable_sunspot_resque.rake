task :environment => :disable_sunspot_resque

task :disable_sunspot_resque do
  ENV['DISABLE_SUNSPOT_RESQUE'] ||= 'true'
end
