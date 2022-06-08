# frozen_string_literal: true

module CobraCommander
  # Calculates directly & transitively affected components
  class Affected
    def initialize(umbrella, changes)
      @umbrella = umbrella
      @changes = changes
      run!
    end

    def names
      @names ||= all_affected.map(&:name)
    end

    def scripts
      @scripts ||= paths.map { |path| File.join(path, "test.sh") }
    end

    def directly
      @directly.map(&method(:affected_component))
    end

    def transitively
      @transitively.map(&method(:affected_component))
    end

    def json_representation
      {
        changed_files: @changes,
        directly_affected_components: directly,
        transitively_affected_components: transitively,
        test_scripts: scripts,
        component_names: names,
        languages: { ruby: contains_ruby?, javascript: contains_js? },
      }.to_json
    end

  private

    def run!
      @transitively = Set.new
      @directly = Set.new
      @umbrella.components.each(&method(:add_if_changed))
      @transitively = @transitively.sort_by(&:name)
      @directly = @directly.sort_by(&:name)
    end

    def component_changed?(component)
      component.root_paths.any? do |component_path|
        @changes.any? do |file_path|
          file_path.start_with?(component_path)
        end
      end
    end

    def add_if_changed(component)
      return unless component_changed?(component)

      @directly << component
      @transitively.merge(component.deep_dependents)
    end

    def affected_component(component)
      {
        name: component.name,
        path: component.root_paths,
        type: component.sources.keys.map(&:to_s).map(&:capitalize).join(" & "),
      }
    end

    def all_affected
      @all_affected ||= (@directly | @transitively).sort_by(&:name)
    end

    def paths
      @paths ||= all_affected.map(&:root_paths).flatten.uniq
    end

    def all_affected_sources
      all_affected
        .map(&:sources)
        .map(&:keys)
        .flatten
        .uniq
    end

    def contains_ruby?
      all_affected_sources.include?(:bundler)
    end

    def contains_js?
      all_affected_sources.include?(:yarn)
    end
  end
end
