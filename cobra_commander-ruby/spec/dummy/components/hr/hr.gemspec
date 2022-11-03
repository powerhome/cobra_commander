# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "hr"
  spec.version = "0.1.0"
  spec.summary = "This is an example component for cobra_commander-ruby"
  spec.authors = ["Carlos Palhares"]

  # External dependencies
  spec.add_dependency "lockbox"

  # Internal dependencies
  spec.add_dependency "authn"
  spec.add_dependency "authz"
  spec.add_dependency "finance"
end
