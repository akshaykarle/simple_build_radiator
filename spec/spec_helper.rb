ENV['RACK_ENV'] ||= 'test'

require ::File.expand_path('../../application.rb',  __FILE__)

require 'rspec'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.backtrace_clean_patterns = []

  config.tty = true

  def app
  Sinatra::Application
  end
end