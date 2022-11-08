# frozen_string_literal: true

require "bundler"
require "bundler/lockfile_parser"
require "pathname"

module CobraCommander
  module Ruby
    # Calculates ruby bundler dependencies
    class Bundle < CobraCommander::Source[:ruby]
      attr_reader :path

      def initialize(root)
        @root = Pathname.new(root)
        @path = @root.join("Gemfile.lock").realpath
        super()
      end

      def root
        Package.new(path: path, dependencies: specs.map(&:name))
      end

      def packages
        @packages ||= specs.map do |spec|
          Package.new(
            name: spec.name,
            path: spec.loaded_from,
            dependencies: spec.dependencies.map(&:name) & root.dependencies
          )
        end
      end

    private

      def lockfile
        @lockfile ||= ::Bundler::LockfileParser.new(::Bundler.read_file(path))
      end

      def sources
        @sources ||= lockfile.sources.filter_map do |source|
          next unless source.path?

          options = source.options.merge!("root_path" => @root)
          ::Bundler::Source::Path.new(options)
        end
      end

      def specs
        @specs ||= sources.flat_map { |source| source.specs.to_a }
      end
    end
  end
end
