require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/bin/"
end

$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'messages_dictionary'

RSpec.configure do |config|
  config.include SpecAddons
  config.include SpecFilesSetup
  config.include SpecUtils
end