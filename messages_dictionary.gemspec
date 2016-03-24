require File.expand_path("../lib/messages_dictionary/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name             = "messages_dictionary"
  spec.version          = MessagesDictionary::VERSION
  spec.authors          = ["Ilya Bodrov", "anilika"]
  spec.email            = ["golosizpru@gmail.com"]
  spec.summary          = %q{Store your messages anywhere and fetch them anytime.}
  spec.description      = %q{This gem allows you to store messages in a simple-key value format and fetch whenever you need. Classes can have different messages and apply different fetching logic. Messages also support interpolation.}
  spec.homepage         = "https://github.com/bodrovis-learning/messages_dictionary"
  spec.license          = "MIT"
  spec.platform         = Gem::Platform::RUBY

  spec.files            = `git ls-files`.split("\n")
  spec.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.extra_rdoc_files = ["README.md"]
  spec.require_paths    = ["lib"]

  spec.add_dependency 'hashie', '~> 3.4'

  spec.add_development_dependency "rake", "~> 10.5"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.5"
end