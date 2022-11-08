# frozen_string_literal: true

require "bundler"
require "bundler/lockfile_parser"
require "pathname"

module CobraCommander
  module Ruby
    # Calculates ruby bundler dependencies
    class Bundle < CobraCommander::Source[:ruby]
      def packages
        @packages ||= specs.map do |spec|
          ::CobraCommander::Package.new(
            self,
            name: spec.name,
            path: spec.loaded_from,
            dependencies: spec.dependencies.map(&:name) & specs.map(&:name)
          )
        end
      end

    private

      def lockfile
        @lockfile ||= ::Bundler::LockfileParser.new(::Bundler.read_file(path.join("Gemfile.lock")))
      end

      def sources
        @sources ||= lockfile.sources.filter_map do |source|
          next unless source.path?

          options = source.options.merge!("root_path" => path)
          ::Bundler::Source::Path.new(options)
        end
      end

      def specs
        @specs ||= sources.flat_map { |source| source.specs.to_a }
      end
    end
  end
end
