# frozen_string_literal: true

module CobraCommander
  # An umbrella application
  class Umbrella
    attr_reader :path

    def initialize(path)
      @path = path
      @components = {}
    end

    def find(name)
      @components[name]
    end

    def resolve(path)
      components.find do |component|
        component.root_paths.any? do |component_path|
          path.start_with?(component_path.to_s)
        end
      end
    end

    def add_source(key, source)
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
