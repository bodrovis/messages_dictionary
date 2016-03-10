require File.expand_path("../lib/pretty_outputter/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name             = "pretty_outputter"
  spec.version          = PrettyOutputter::VERSION
  spec.authors          = ["Ilya Bodrov", "anilika"]
  spec.email            = ["golosizpru@gmail.com"]
  spec.summary          = %q{}
  spec.description      = %q{}
  spec.homepage         = ""
  spec.license          = "MIT"
  spec.platform         = Gem::Platform::RUBY

  spec.files            = `git ls-files`.split("\n")
  spec.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.extra_rdoc_files = ["README.md"]
  spec.require_paths    = ["lib"]
end