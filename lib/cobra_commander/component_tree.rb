# frozen_string_literal: true

require "cobra_commander/component_tree/gem_component_tree"
require "cobra_commander/component_tree/node_component_tree"

module CobraCommander
  # Representation of the tree of components and their dependencies
  class ComponentTree
    def initialize(path)
      @root_path = path
    end

    def to_h
      {
        name: UMBRELLA_APP_NAME,
        path: @root_path,
        ancestry: Set.new,
        dependencies: gem_h[:dependencies] + node_h[:dependencies],
      }
    end

    def node_h
      @node_h ||= NodeComponentTree.new(UMBRELLA_APP_NAME, @root_path).to_h
    end

    def gem_h
      @gem_h ||= GemComponentTree.new(UMBRELLA_APP_NAME, @root_path).to_h
    end
  end
end
