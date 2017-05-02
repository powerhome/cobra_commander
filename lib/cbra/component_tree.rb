# frozen_string_literal: true

require "thor"

module Cbra
  # Representation of the tree of components and their dependencies
  class ComponentTree
    def initialize(path)
      @root_path = path
    end

    def to_h
      GemComponentTree.new("App", @root_path).to_h
    end

    # Represents a tree of gem components with dependencies extracted via Bundler
    class GemComponentTree
      def initialize(name, path)
        @name = name
        @root_path = path
      end

      def to_h
        {
          name: @name,
          dependencies: component_dependencies.map(&method(:dep_representation)),
        }
      end

    private

      def gemfile_path
        File.join(@root_path, "Gemfile")
      end

      def gemfile_lock_path
        File.join(@root_path, "Gemfile.lock")
      end

      def bundler_definition
        ::Bundler::Definition.build(gemfile_path, gemfile_lock_path, nil)
      end

      def component_dependencies
        bundler_definition.dependencies.select do |dep|
          dep.source && dep.source.is_a_path?
        end
      end

      def dep_representation(dep)
        path = File.expand_path(File.join(@root_path, dep.source.path, dep.name))
        self.class.new(dep.name, path).to_h
      end
    end
  end
end