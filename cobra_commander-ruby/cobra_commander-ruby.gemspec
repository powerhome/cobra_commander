# frozen_string_literal: true

require_relative "lib/cobra_commander/ruby/version"

Gem::Specification.new do |spec|
  spec.name = "cobra_commander-ruby"
  spec.version = CobraCommander::Ruby::VERSION
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
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/powerhome/cobra_commander"
  spec.metadata["changelog_uri"] = "https://github.com/powerhome/cobra_commander/blob/main/cobra_commander-ruby/docs/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{docs,lib}/**/*"] + ["cobra_commander-ruby.gemspec"]
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "license_finder", ">= 7.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "1.30.1"
  spec.add_development_dependency "rubocop-powerhome", ">= 0.5.0"
end
