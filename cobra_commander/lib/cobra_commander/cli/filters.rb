# frozen_string_literal: true

module CobraCommander
  # @private
  class CLI
    private_class_method def self.filter_options(dependents:, dependencies:)
      method_option :affected, type: :string, desc: "Components affected since given branch [default: main]"
      method_option :dependencies, type: :boolean, aliases: "-d", desc: dependencies
      method_option :dependents, type: :boolean, aliases: "-D", desc: dependents
      method_option :self, type: :boolean, default: true, desc: "Include the own component"
    end

  private

    def find_component(name)
      umbrella.find(name) || error("Component #{name} not found, maybe #{suggestion(name)}") || exit(1)
    end

    def suggestion(name)
      [*suggestions(name), 'one of "cobra ls"'].join(", ")
    end

    def suggestions(name)
      spell_checker = DidYouMean::SpellChecker.new(dictionary: umbrella.components.map(&:name))
      spell_checker.correct(name)
    rescue NameError
      []
    end

    def affected_by_changes(origin_branch)
      changes = GitChanged.new(umbrella.path, origin_branch)
      Affected.new(umbrella, changes).all
    end

    def filter_component(component_name)
      component = find_component(component_name)
      components = []
      components << component if options.self
      components += component.deep_dependencies if options.dependencies
      components += component.deep_dependents if options.dependents
      components
    end

    def filter_components(component_names)
      component_names.reduce(Set.new) do |set, name|
        set | filter_component(name)
      end
    end

  protected

    def components_filtered(names)
      components = names ? filter_components(names.split(",")) : umbrella.components
      components &= affected_by_changes(options.affected) if options.affected
      components
    end
  end
end
