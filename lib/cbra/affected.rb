# frozen_string_literal: true

module Cbra
  # Calculates directly & transitively affected components
  class Affected
    attr_reader :directly, :transitively

    def initialize(tree, changes, path)
      @changes = changes
      @path = path
      @transitively = []
      @directly = []
      calculate(tree)
    end

    def needing_test_runs
      @needing_test_runs ||= begin
        components = (@directly + @transitively).uniq
        components.each_with_object([]) do |component, tests|
          tests << File.join(component[:path], "test.sh")
        end
      end
    end

  private

    def calculate(component)
      find_dependencies(component) && cleanup
    end

    def find_dependencies(parent_component)
      parent_component[:dependencies].each do |component|
        add_if_changed(component)
        find_dependencies(component)
      end
    end

    def add_if_changed(component)
      @changes.each do |change|
        if change.start_with?(component[:path])
          @directly << component.reject { |k| k == :dependencies || k == :ancestry }
          @transitively << component[:ancestry]
        end
      end
    end

    def cleanup
      @directly.uniq!
      @transitively.flatten!
      @transitively.uniq!
      @transitively.delete(name: "App", path: @path)
    end
  end
end
