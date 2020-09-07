# frozen_string_literal: true

require "bundler"
require "bundler/lockfile_parser"
require "pathname"

module CobraCommander
  module Dependencies
    # Calculates ruby bundler dependencies
    class Bundler
      attr_reader :path

      def initialize(root)
        @root = root
        @path = Pathname.new(File.join(root, "Gemfile.lock")).realpath
      end

      def dependencies
        lockfile.dependencies.values.map(&:name)
      end

      def components
        components_source.specs.map do |spec|
          { path: spec.loaded_from, name: spec.name, dependencies: spec.dependencies.map(&:name) }
        end
      end

    private

      def lockfile
        @lockfile ||= ::Bundler::LockfileParser.new(::Bundler.read_file(path))
      end

      def components_source
        @components_source ||= begin
          source = @lockfile.sources.find { |s| s.path.to_s.eql?("components") }
          ::Bundler::Source::Path.new(source.options.merge("root_path" => @root))
        end
      end
    end
  end
end
