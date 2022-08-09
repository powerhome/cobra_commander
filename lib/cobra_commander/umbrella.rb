# frozen_string_literal: true

module CobraCommander
  # An umbrella application
  class Umbrella
    attr_reader :name, :path

    def initialize(name, path)
      @root_component = Component.new(self, name)
      @path = path
      @components = {}
    end

    def find(name)
      @components[name]
    end

    def root
      @root_component
    end

    def resolve(component_root_path)
      return root if root.root_paths.include?(component_root_path)

      components.find do |component|
        component.root_paths.include?(component_root_path)
      end
    end

    def add_source(key, source)
      @root_component.add_source key, source.path, source.dependencies
      source.components.each do |component|
        @components[component[:name]] ||= Component.new(self, component[:name])
        @components[component[:name]].add_source key, component[:path], component[:dependencies]
      end
    end

    def components
      @components.values
    end
  end
end
