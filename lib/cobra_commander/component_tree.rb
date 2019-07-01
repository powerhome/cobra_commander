# frozen_string_literal: true

require "bundler"
require "json"

module CobraCommander
  # Represents a dependency tree in a given context
  class ComponentTree
    attr_reader :name, :path

    def initialize(name, path, ancestry = Set.new)
      @name = name
      @path = path
      @ancestry = ancestry
      @ruby = Ruby.new(path)
      @js = Js.new(path)
      @type = type_of_component
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

    def to_h
      {
        name: @name,
        path: path,
        type: @type,
        ancestry: @ancestry,
        dependencies: dependencies.map(&:to_h),
      }
    end

    def dependencies
      @deps ||= begin
        deps = @ruby.dependencies + @js.dependencies
        deps.sort_by { |dep| dep[:name] }
            .map(&method(:dep_representation))
      end
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

    def type_of_component
      return "Ruby & JS" if @ruby.gem? && @js.node?
      return "Ruby" if @ruby.gem?
      return "JS" if @js.node?
    end

    def dep_representation(dep)
      full_path = File.expand_path(File.join(path, dep[:path]))
      ancestry = @ancestry + [{ name: @name, path: path, type: @type }]
      ComponentTree.new(dep[:name], full_path, ancestry)
    end
  end
end
