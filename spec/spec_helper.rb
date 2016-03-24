require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'messages_dictionary'