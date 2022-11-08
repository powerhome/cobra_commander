# frozen_string_literal: true

module CobraCommander
  # Calculates directly & transitively affected components
  class Affected
    def initialize(umbrella, changes)
      @umbrella = umbrella
      @changes = changes
    end

    def names
      @names ||= all.map(&:name)
    end

    def all
      @all ||= (directly | transitively).sort_by(&:name)
    end

    def scripts
      @scripts ||= paths.map { |path| File.join(path, "test.sh") }
    end

    def directly
      @directly ||= @changes.filter_map { |path| @umbrella.resolve(path) }
                            .uniq.sort_by(&:name)
    end

    def transitively
      @transitively ||= directly.flat_map(&:deep_dependents)
                                .uniq.sort_by(&:name)
    end

    def to_json(*_args)
      {
        changed_files: @changes,
        directly_affected_components: directly.map(&method(:affected_component)),
        transitively_affected_components: transitively.map(&method(:affected_component)),
        test_scripts: scripts,
        component_names: names,
        languages: all_affected_packages,
      }.to_json
    end

  private

    def affected_component(component)
      {
        name: component.name,
        path: component.root_paths,
        type: component.packages.map(&:key).map(&:to_s),
      }
    end

    def paths
      @paths ||= all.map(&:root_paths).flatten
    end

    def all_affected_packages
      all.flat_map(&:packages).map(&:key).uniq
    end
  end
end
