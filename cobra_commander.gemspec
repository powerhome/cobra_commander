# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cobra_commander/version"

Gem::Specification.new do |spec|
  spec.name = "cobra_commander"
  spec.version = CobraCommander::VERSION
  spec.authors = [
    "Ben Langfeld",
    "Garett Arrowood",
    "Carlos Palhares"
  ]
  spec.email = [
    "blangfeld@powerhrg.com",
    "garett.arrowood@powerhrg.com",
    "carlos.palhares@powerhrg.com"
  ]
  spec.summary = "Tools for working with Component Based Rails Apps"
  spec.description = <<~DESCRIPTION
    Tools for working with Component Based Rails Apps (see https://cbra.info).
    Includes tools for graphing the components of an app and their relationships, as well as selectively
    testing components based on changes made.
  DESCRIPTION
  spec.homepage = "http://tech.powerhrg.com/cobra_commander/"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler"
  spec.add_dependency "concurrent-ruby", "~> 1.1"
  spec.add_dependency "ruby-graphviz", "~> 1.2.3"
  spec.add_dependency "thor", ["< 2.0", ">= 0.18.1"]
  spec.add_dependency "tty-command", "~> 0.10.0"
  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "tty-spinner", "~> 0.9.3"

  spec.add_development_dependency "aruba", "~> 0.14.2"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "standard", ">= 1.3.0"
end
