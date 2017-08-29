# frozen_string_literal: true

require "cobra_commander/component_tree/gem_component_tree"

module CobraCommander
  # Representation of the tree of components and their dependencies
  class ComponentTree
    def initialize(path)
      @root_path = path
    end

    def to_h
      GemComponentTree.new(UMBRELLA_APP_NAME, @root_path).to_h
    end
  end
end
