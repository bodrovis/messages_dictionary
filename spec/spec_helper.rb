# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/bin/'
end

if ENV.fetch('CI', nil) == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

$LOAD_PATH << File.expand_path('../../lib', __dir__)

RSPEC_ROOT = File.dirname __FILE__

Dir["#{RSPEC_ROOT}/support/**/*.rb"].sort.each { |f| require f }

require 'messages_dictionary'

RSpec.configure do |config|
  config.include SpecFilesSetup
  config.include SpecUtils
end
