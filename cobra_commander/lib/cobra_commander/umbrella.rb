# frozen_string_literal: true

module CobraCommander
  # An umbrella application
  class Umbrella
    attr_reader :path

    def initialize(path, **source_selector)
      @path = path
      @components = {}
      load(source_selector)
    end

    def find(name)
      @components[name]
    end

    def resolve(path)
      components.find do |component|
        component.root_paths.any? do |component_path|
          path.to_s.start_with?(component_path.cleanpath.to_s)
        end
      end
    end

    def load(**source_selector)
      Source.load(path, **source_selector).each do |package|
        @components[package.name] ||= Component.new(self, package.name)
        @components[package.name].add_package package
      end
    end

    def components
      @components.values
    end
  end
end
