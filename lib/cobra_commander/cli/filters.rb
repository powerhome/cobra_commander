# frozen_string_literal: true

module CobraCommander
  # @private
  class CLI
    private_class_method def self.filter_options(dependents:, dependencies:)
      method_option :dependencies, type: :boolean, aliases: "-d", desc: dependencies
      method_option :dependents, type: :boolean, aliases: "-D", desc: dependents
      method_option :self, type: :boolean, default: true, desc: "Include the own component"
    end

    private

    def find_component(name)
      return umbrella.root unless name

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

    def components_filtered(component_name)
      return umbrella.components unless component_name

      component = find_component(component_name)
      components = options.self ? [component] : []
      components.concat component.deep_dependencies if options.dependencies
      components.concat component.deep_dependents if options.dependents
      components
    end
  end
end
