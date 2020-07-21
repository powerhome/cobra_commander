# frozen_string_literal: true

require "thor"
require "fileutils"

require "cobra_commander"
require "cobra_commander/affected"
require "cobra_commander/change"
require "cobra_commander/executor"
require "cobra_commander/output"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    class_option :app, default: Dir.pwd, aliases: "-a", type: :string
    class_option :js, default: false, type: :boolean, desc: "Consider only the JS dependency graph"
    class_option :ruby, default: false, type: :boolean, desc: "Consider only the Ruby dependency graph"

    desc "version", "Prints version"
    def version
      puts CobraCommander::VERSION
    end

    desc "ls", "Lists the components in the context of a given component or umbrella"
    method_option :dependencies, type: :boolean, aliases: "-d", desc: "Run the command on each dependency of a given component"
    method_option :dependents, type: :boolean, aliases: "-D", desc: "Run the command on each dependency of a given component"
    method_option :total, type: :boolean, aliases: "-t", desc: "Prints the total count of components"
    def ls(component = nil)
      components = components_filtered(component)
      puts options.total ? components.size : CobraCommander::Output::FlatList.new(components).to_s
    end

    desc "exec", "Executes the command in the context of a given component or set of components"
    method_option :dependencies, type: :boolean, desc: "Run the command on each dependency of a given component"
    method_option :dependents, type: :boolean, desc: "Run the command on each dependency of a given component"
    def exec(command_or_component, command = nil)
      CobraCommander::Executor.exec(
        components_filtered(command && command_or_component),
        command ? command : command_or_component
      )
    end

    desc "tree", "Prints the dependency tree of a given component or umbrella"
    def tree(component = nil)
      component = find_component(component)
      puts CobraCommander::Output::AsciiTree.new(component).to_s
    end

    desc "graph", "Outputs a graph of a given component or umbrella"
    method_option :output, default: File.join(Dir.pwd, "output.png"), aliases: "-o", desc: "Output file, accepts .png or .dot"
    def graph(component = nil)
      CobraCommander::Output::GraphViz.generate(
        find_component(component),
        options.output
      )
      puts "Graph generated at #{options.output}"
    rescue ArgumentError => error
      error error.message
    end

    desc "changes [--results=RESULTS] [--branch=BRANCH]", "Prints list of changed files"
    method_option :results, default: "test", aliases: "-r", desc: "Accepts test, full, name or json"
    method_option :branch, default: "master", aliases: "-b", desc: "Specified target to calculate against"
    def changes
      Change.new(umbrella, options.results, options.branch).run!
    end

  private

    def umbrella
      @umbrella ||= CobraCommander.umbrella(options.app, yarn: options.js, bundler: options.ruby)
    end

    def find_component(name)
      return umbrella.root unless name

      umbrella.find(name) || error("Component #{name} not found, try one of `cobra ls`") || exit(1)
    end

    def components_filtered(component_name)
      if component_name
        component = find_component(component_name)
        if options.dependencies
          component.deep_dependencies
        elsif options.dependents
          component.deep_dependents
        else
          [component]
        end
      else
        umbrella.components
      end
    end
  end
end
