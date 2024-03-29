# frozen_string_literal: true

require "yaml"

module CobraCommander
  # An umbrella application
  class Umbrella
    attr_reader :path, :config

    def self.load_config(path)
      return {} unless path.exist?

      YAML.safe_load(path.read, permitted_classes: [Symbol], aliases: true)
    end

    # Umbrella constructor. This will load the given source packages.
    #
    # @see Umbrella#load
    # @param path [String,Pathname] path to umbrella app
    # @param **source_selector [Symbol => Boolean] selector as explained above
    #
    def initialize(path, config = nil, **source_selector)
      @path = Pathname.new(path)
      @components = {}
      @config = config || Umbrella.load_config(@path.join("cobra.yml"))
      load(**source_selector)
    end

    #
    # Finds a component by name
    #
    # @param name [String] the name of the component
    # @return [::CobraCommander::Component,nil] the component with a matching name or nil
    #
    def find(name)
      @components[name]
    end

    #
    # Resolve a component given the path.
    #
    # This method resolves the component if the given path is inside
    # any of the packages composing this component.
    #
    # @param path [String,Pathname] the path to be resolved
    # @return [::CobraCommander::Component,nil] the component where the path is
    #
    def resolve(path)
      components.find do |component|
        component.root_paths.any? do |component_path|
          component_path.eql?(path) || path.expand_path.to_s.start_with?("#{component_path.expand_path}/")
        end
      end
    end

    #
    # Loads the given sources, or all of none given. This method is fired
    # by the constructor with the inital selector.
    #
    # I.e.:
    #
    #   If the environment has both ruby and yarn plugins loaded, this
    #   would load the yarn workspaces packages and rubygems package
    #   graphs:
    #
    #      umbrella.load(ruby: true, js: true)
    #
    #   If no selector is given, all plugins are loaded. So assuming the
    #   same plugins exist, this would also load yarn and ruby packages:
    #
    #      umbrella.load()
    #
    #   Specifying plugins will only load what is specified, and this would
    #   only load ruby packages:
    #
    #      umbrella.load(ruby: true)
    #
    # @see CobraCommander::Registry
    #
    def load(**source_selector)
      Source.load(path, config["sources"], **source_selector).flatten.each do |package|
        @components[package.name] ||= Component.new(self, package.name)
        @components[package.name].add_package package
      end
    end

    # All components in this umbrella
    #
    # @return [Array<CobraCommander::Component>]
    #
    def components
      @components.values
    end
  end
end
