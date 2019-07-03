# frozen_string_literal: true

require "bundler"
require "json"

module CobraCommander
  # Represents a dependency tree in a given context
  class ComponentTree
    attr_reader :name, :path

    def initialize(name, path)
      @name = name
      @path = path
    end

    def flatten
      _flatten(self)
    end

    def subtree(name)
      _subtree(name, self)
    end

    def depends_on?(component_name)
      dependencies.any? do |component|
        component.name == component_name || component.depends_on?(component_name)
      end
    end

    def dependents_of(component_name)
      depends = depends_on?(component_name) ? self : nil
      dependents_below = dependencies.map do |component|
        component.dependents_of(component_name)
      end
      [depends, dependents_below].flatten.compact.uniq(&:name)
    end

    def to_h(json_compatible: false)
      {
        name: @name,
        path: path,
        type: @type,
        ancestry: json_compatible ? @ancestry.to_a : @ancestry,
        dependencies: dependencies.map { |dep| dep.to_h(json_compatible: json_compatible) },
      }
    end

    def to_json
      JSON.dump(to_h(json_compatible: true))
    end

  private

    def _flatten(component)
      component.dependencies.map do |dep|
        [dep] + _flatten(dep)
      end.flatten.uniq(&:name)
    end

    def _subtree(name, tree)
      return tree if tree.name == name
      tree.dependencies.each do |component|
        presence = _subtree(name, component)
        return presence if presence
      end
      nil
    end
  end
end
