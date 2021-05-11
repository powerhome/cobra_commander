# frozen_string_literal: true

module CobraCommander
  # @private
  class CLI
    private_class_method def self.filter_options(dependents:, dependencies:)
      method_option :dependencies, type: :boolean, aliases: "-d", desc: dependencies
      method_option :dependents, type: :boolean, aliases: "-D", desc: dependents
      method_option :self, type: :boolean, desc: "Include the own component"
    end

  private

    def find_component(name)
      return umbrella.root unless name

      umbrella.find(name) || error("Component #{name} not found, try one of `cobra ls`") || exit(1)
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
