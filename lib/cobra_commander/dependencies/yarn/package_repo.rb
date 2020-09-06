# frozen_string_literal: true

module CobraCommander
  module Dependencies
    module Yarn
      # Yarn package repository to load and cache package.json files
      class PackageRepo
        def initialize
          @specs = {}
        end

        def specs
          @specs.values
        end

        def load_linked_specs(package)
          package.dependencies.each_value do |spec|
            next unless spec =~ /link:(.+)/

            load_spec(File.join(package.path, "..", Regexp.last_match(1)))
          end
        end

        def load_spec(path)
          @specs[path] ||= Package.new(path).tap do |package|
            load_linked_specs(package)
          end
        end
      end
    end
  end
end
