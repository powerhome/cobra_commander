# frozen_string_literal: true

require_relative "lib/cobra_commander/version"

Gem::Specification.new do |spec|
  spec.name = "cobra_commander"
  spec.version = CobraCommander::VERSION
  spec.authors = [
    "Ben Langfeld",
    "Garett Arrowood",
    "Carlos Palhares",
  ]
  spec.email = [
    "blangfeld@powerhrg.com",
    "garett.arrowood@powerhrg.com",
    "carlos.palhares@powerhrg.com",
  ]
  spec.summary = "Tools for working with Component Based Rails Apps"
  spec.description = <<~DESCRIPTION
    Tools for working with Component Based Rails Apps (see https://cbra.info).
    Includes tools for graphing the components of an app and their relationships, as well as selectively
    testing components based on changes made.
  DESCRIPTION
  spec.homepage = "http://tech.powerhrg.com/cobra_commander/"
  spec.license = "MIT"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/powerhome/cobra_commander"
  spec.metadata["changelog_uri"] = "https://github.com/powerhome/cobra_commander/blob/main/cobra_commander/docs/CHANGELOG.md"

  spec.files = Dir["{docs,exe,lib}/**/*"] + ["cobra_commander.gemspec"]
  spec.bindir = "exe"
  spec.executables = %w[cobra]
  spec.require_paths = %w[lib]

  spec.add_dependency "bundler"
  spec.add_dependency "concurrent-ruby", "~> 1.1"
  spec.add_dependency "thor", ["< 2.0", ">= 0.18.1"]
  spec.add_dependency "tty-command", "~> 0.10.0"
  spec.add_dependency "tty-prompt", "~> 0.23.1"

  spec.add_development_dependency "aruba", "~> 0.14.2"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "license_finder", ">= 7.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "1.30.1"
  spec.add_development_dependency "rubocop-powerhome", ">= 0.5.0"
end
