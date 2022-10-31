# frozen_string_literal: true

require_relative "lib/cobra_commander/yarn/version"

Gem::Specification.new do |spec|
  spec.name = "cobra_commander-yarn"
  spec.version = CobraCommander::Yarn::VERSION
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

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/powerhome/cobra_commander"
  spec.metadata["changelog_uri"] = "https://github.com/powerhome/cobra_commander/blob/main/cobra_commander-yarn/docs/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]
end
