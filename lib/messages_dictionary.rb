# frozen_string_literal: true

require 'yaml'
require 'hashie'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module MessagesDictionary
end
