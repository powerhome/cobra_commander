# frozen_string_literal: true

module CobraCommander
  module Dependencies
    # Calculates ruby bundler dependencies
    class Bundler
      def initialize(root)
        @definition = ::Bundler::Definition.build(
          Pathname.new(File.join(root, "Gemfile")).realpath,
          Pathname.new(File.join(root, "Gemfile.lock")).realpath,
          false
        )
      end

      def path
        @definition.lockfile
      end

      def dependencies
        @definition.dependencies.map(&:name)
      end

      def components
        components_source.specs.map do |spec|
          { path: spec.loaded_from, name: spec.name, dependencies: spec.dependencies.map(&:name) }
        end
      end

    private

      def components_source
        @components_source ||= @definition.send(:sources).path_sources.find do |source|
          source.path.to_s.eql?("components")
        end
      end
    end
  end
end
