# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)

run Stats::Application

# require 'resque/server'
# require 'resque-cleaner'
# run Rack::URLMap.new \
#   "/"       => Stats::Application,
#   "/resque" => Resque::Server.new