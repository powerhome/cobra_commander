# frozen_string_literal: true

require "bundler"
require "bundler/lockfile_parser"
require "pathname"

module CobraCommander
  module Ruby
    # Calculates ruby bundler dependencies
    class Bundle < CobraCommander::Source[:ruby]
      def packages
        specs.map do |spec|
          ::CobraCommander::Package.new(
            self,
            name: spec.name,
            path: Pathname.new(spec.loaded_from).dirname,
            dependencies: spec.dependencies.map(&:name) & specs.map(&:name)
          )
        end
      end

      # Runs the command with the ambient Bundler environment stripped, so a
      # nested `bundle` call resolves the package's own bundle rather than
      # cobra's, and points BUNDLE_APP_CONFIG at the umbrella's .bundle
      # directory so that bundle config is read from the umbrella. Only the
      # ruby plugin isolates the bundle this way.
      def around_command
        ::Bundler.with_unbundled_env do
          yield({ "BUNDLE_APP_CONFIG" => path.join(".bundle").to_s })
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
        @specs ||= sources.flat_map { |source| source.specs.to_a }.uniq
      end
    end
  end
end
