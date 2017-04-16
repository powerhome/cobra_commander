# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cbra/version'

Gem::Specification.new do |spec|
  spec.name          = "cbra"
  spec.version       = Cbra::VERSION
  spec.authors       = ["Ben Langfeld"]
  spec.email         = ["blangfeld@powerhrg.com"]

  spec.summary       = %q{Tools for working with Component Based Rails Apps}
  spec.description   = %q{Tools for working with Component Based Rails Apps (see http://shageman.github.io/cbra.info/). Includes tools for graphing the components of an app and their relationships, as well as selectively testing components based on changes made.}
  spec.homepage      = "http://tech.powerhrg.com/cbra/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
