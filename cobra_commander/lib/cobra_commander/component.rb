# frozen_string_literal: true

module CobraCommander
  # Represents a component withing an Umbrella
  class Component
    attr_reader :name, :packages

    def initialize(umbrella, name)
      @umbrella = umbrella
      @name = name
      @dependency_names = []
      @packages = []
    end

    def describe
      "#{name} (#{packages.map(&:key).join(', ')})"
    end

    def add_package(package)
      @packages << package
      @dependency_names |= package.dependencies
    end

    def root_paths
      @packages.map(&:path).uniq
    end

    def inspect
      "#<CobraCommander::Component:#{object_id} #{name} dependencies=#{dependencies.map(&:name)} packages=#{packages}>"
    end

    def deep_dependents
      @deep_dependents ||= @umbrella.components.find_all do |dep|
        dep.deep_dependencies.include?(self)
      end
    end

    def deep_dependencies
      @deep_dependencies ||= dependencies.reduce(dependencies) do |deps, dep|
        deps | dep.deep_dependencies
      end
    end

    def dependents
      @dependents ||= @umbrella.components.find_all do |dep|
        dep.dependencies.include?(self)
      end
    end

    def dependencies
      @dependencies ||= @dependency_names.sort.filter_map { |name| @umbrella.find(name) }
    end
  end
end
