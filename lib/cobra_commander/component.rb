# frozen_string_literal: true

module CobraCommander
  # Represents a component withing an Umbrella
  class Component
    attr_reader :name, :sources

    def initialize(umbrella, name)
      @umbrella = umbrella
      @name = name
      @dependency_names = []
      @sources = {}
    end

    def add_source(key, path, dependency_names)
      @sources[key] = path
      @dependency_names |= dependency_names
    end

    def root_paths
      @sources.values.map(&File.method(:dirname)).uniq
    end

    def inspect
      "#<CobraCommander::Component:#{object_id} #{name} dependencies=#{dependencies.map(&:name)} packages=#{sources}>"
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
      @dependencies ||= @dependency_names.sort
                                         .map(&@umbrella.method(:find))
                                         .compact
    end
  end
end
