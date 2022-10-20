# frozen_string_literal: true

require "bundler"
require "bundler/lockfile_parser"
require "pathname"

module CobraCommander
  module Dependencies
    # Calculates ruby bundler dependencies
    class Bundler
      autoload :Package, "cobra_commander/dependencies/bundler/package"

      attr_reader :path

      def initialize(root)
        @root = Pathname.new(root)
        @path = @root.join("Gemfile.lock").realpath
      end

      def root
        Package.new(path: path, dependencies: lockfile.dependencies.values)
      end

      def packages
        @packages ||= components_sources.flat_map do |source|
          source.specs.map { |spec| Package.new(spec) }
        end
      end

    private

      def lockfile
        @lockfile ||= ::Bundler::LockfileParser.new(::Bundler.read_file(path))
      end

      def components_sources
        @components_sources ||= @lockfile.sources.filter_map do |source|
          next unless source.path?

          options = source.options.merge!("root_path" => @root)
          ::Bundler::Source::Path.new(options)
        end
      end
    end
  end
end
