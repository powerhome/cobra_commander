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

    def resolve(path)
      components.find do |component|
        component.root_paths.any? do |component_path|
          path.start_with?(component_path.to_s)
        end
      end
    end

    def add_source(key, source)
      @root_component.add_package key, source.root
      source.packages.each do |packages|
        @components[packages.name] ||= Component.new(self, packages.name)
        @components[packages.name].add_package key, packages
      end
    end

    def components
      @components.values
    end
  end
end
