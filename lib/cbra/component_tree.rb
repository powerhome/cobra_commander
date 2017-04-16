# frozen_string_literal: true

require "thor"

module Cbra
  # Representation of the tree of components and their dependencies
  class ComponentTree
    def initialize(path)
      @root_path = path
    end

    def to_h
      {
        name: "App",
        dependencies: component_dependencies.map(&method(:dep_representation)),
      }
    end

  private

    def bundler_definition
      gemfile_path = File.join(@root_path, "Gemfile")
      lockfile_path = File.join(@root_path, "Gemfile.lock")
      ::Bundler::Definition.build(gemfile_path, lockfile_path, nil)
    end

    def component_dependencies
      bundler_definition.dependencies.select do |dep|
        dep.source && dep.source.is_a_path?
      end
    end

    def dep_representation(dep)
      { name: dep.name, dependencies: [] }
    end
  end
end
