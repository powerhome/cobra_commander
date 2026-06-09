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

    # Wraps the execution of a command on this component by nesting the
    # around_command of each distinct source backing its packages, so every
    # package gets a chance to enhance the surrounding process. The env vars
    # each source yields are merged (later sources win) and the merged hash is
    # yielded to the block.
    #
    # @yieldparam env [Hash{String => String}] merged env vars for the command
    # @return the value returned by the block
    def around_command(&block)
      nest_sources(@packages.map(&:source).uniq, {}, &block)
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

  private

    # Nests each source's #around_command, accumulating the env each yields,
    # and finally yields the merged env to the block.
    def nest_sources(sources, env, &block)
      return block.call(env) if sources.empty?

      head, *rest = sources
      head.around_command do |source_env|
        nest_sources(rest, env.merge(source_env), &block)
      end
    end
  end
end
