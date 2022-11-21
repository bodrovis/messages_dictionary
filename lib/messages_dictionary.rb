# frozen_string_literal: true

require 'yaml'
require 'hashie'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Store your messages anywhere and fetch them anytime.
# For example:
#
#   class MyClass
#     include MessagesDictionary
#     has_messages_dictionary

#     def calculate(a)
#       result = a ** 2
#       pretty_output(:show_result, result: result)
#     end
#   end
module MessagesDictionary
  def self.included(klass)
    klass.include MessagesDictionary::Injector
  end
end
