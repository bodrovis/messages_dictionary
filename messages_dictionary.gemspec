# frozen_string_literal: true

require File.expand_path('lib/messages_dictionary/version', __dir__)

Gem::Specification.new do |spec|
  spec.name             = 'messages_dictionary'
  spec.version          = MessagesDictionary::VERSION
  spec.authors          = ['Ilya Krukowski', 'anilika']
  spec.email            = ['golosizpru@gmail.com']
  spec.summary          = 'Store your messages anywhere and fetch them anytime.'
  spec.description      = 'This gem allows you to store some text in a simple-key value format and fetch ' \
                          'it whenever you need from your methods. Various classes may have different ' \
                          'messages attached and apply different fetching logic. Messages also support ' \
                          'interpolation and can be stored in separate YAML files.'
  spec.homepage         = 'https://github.com/bodrovis-learning/messages_dictionary'
  spec.license          = 'MIT'
  spec.platform         = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'
  spec.files            = `git ls-files`.split("\n")
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths    = ['lib']

  spec.add_dependency 'hashie', '~> 5.0'
  spec.add_dependency 'zeitwerk', '~> 2.4'

  spec.add_development_dependency 'codecov', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'rubocop',             '~> 1.6'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rake',        '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec',       '~> 2.0'
  spec.add_development_dependency 'simplecov',           '~> 0.16'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
