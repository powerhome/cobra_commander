# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "finance"
  spec.version = "0.1.0"
  spec.summary = "This is an example component for cobra_commander-ruby"
  spec.authors = ["Carlos Palhares"]
  spec.license = "MIT"

  spec.add_dependency "authn"
  spec.add_dependency "authz"
  spec.metadata["rubygems_mfa_required"] = "true"
end
