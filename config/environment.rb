# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'
require 'themoviedb'
require 'json'

require 'yaml'
require 'uri'
require 'pathname'

require 'pg'
require 'active_record'
require 'logger'

require 'sinatra'
require "sinatra/reloader" if development?

require 'koala'
require 'erb'
require 'yaml'

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

env_config = YAML.load_file(APP_ROOT.join('config', 'facebook.yml'))
env_config.each do |key, value|
  ENV[key] = value
end



configure do
  set :root, APP_ROOT.to_path

  use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']

  # Set the views to
  set :views, File.join(Sinatra::Application.root, "app", "views")
end

secrets = YAML.load_file('config/secret.yaml')
Tmdb::Api.key(secrets["API_KEY"])


# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }

# Set up the database and models
require APP_ROOT.join('config', 'database')


