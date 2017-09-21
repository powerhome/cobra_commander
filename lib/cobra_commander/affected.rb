# frozen_string_literal: true

module CobraCommander
  # Calculates directly & transitively affected components
  class Affected
    attr_reader :directly, :transitively

    def initialize(tree, changes, path)
      @tree = tree
      @changes = changes
      @path = path
      run!
    end

    def names
      @names ||= paths.map! { |path| File.basename(path) }
    end

    def scripts
      @paths ||= paths.map! { |path| File.join(path, "test.sh") }
    end

  private

    def run!
      @transitively = Set.new
      @directly = Set.new
      find_dependencies(@tree)
      @transitively.delete(name: UMBRELLA_APP_NAME, path: @path, type: @tree[:type])
      @transitively = @transitively.to_a.sort_by { |h| h[:name] }
      @directly = @directly.to_a.sort_by { |h| h[:name] }
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
          @transitively.merge component[:ancestry]
        end
      end
    end

    def all_affected
      (@directly + @transitively).uniq.sort_by { |h| h[:path] }
    end

    def paths
      @paths ||= all_affected.map! { |component| component[:path] }
    end
  end
end
