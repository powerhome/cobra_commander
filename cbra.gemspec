# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cbra/version"

Gem::Specification.new do |spec|
  spec.name          = "cbra"
  spec.version       = Cbra::VERSION
  spec.authors       = ["Ben Langfeld"]
  spec.email         = ["blangfeld@powerhrg.com"]

  spec.summary       = "Tools for working with Component Based Rails Apps"
  spec.description   = <<~DESCRIPTION
    Tools for working with Component Based Rails Apps (see http://shageman.github.io/cbra.info/).
    Includes tools for graphing the components of an app and their relationships, as well as selectively
    testing components based on changes made.
DESCRIPTION
  spec.homepage      = "http://tech.powerhrg.com/cbra/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19.4"
  spec.add_dependency "ruby-graphviz", "~> 1.2.3"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "aruba", "~> 0.14.2"
  spec.add_development_dependency "rubocop", "0.48.1"
  spec.add_development_dependency "pry"
end
