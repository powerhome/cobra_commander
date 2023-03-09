# frozen_string_literal: true

require "etc"
require "thor"
require "fileutils"
require "cobra_commander"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    DEFAULT_CONCURRENCY = (Etc.nprocessors / 2.0).ceil

    require_relative "cli/filters"
    require_relative "cli/output/ascii_tree"
    require_relative "cli/output/change"
    require_relative "cli/output/dot_graph"

    class_option :app, default: Dir.pwd, aliases: "-a", type: :string
    Source.all.keys.each do |key|
      class_option key, default: false, type: :boolean, desc: "Consider only the #{key} dependency graph"
    end

    desc "version", "Prints version"
    def version
      puts CobraCommander::VERSION
    end

    desc "ls [components]", "Lists the components in the context of a given component or umbrella"
    filter_options dependents: "Lists all dependents of a given component",
                   dependencies: "Lists all dependencies of a given component"
    method_option :total, type: :boolean, aliases: "-t", desc: "Prints the total count of components"
    def ls(components = nil)
      components = components_filtered(components)
      puts options.total ? components.size : components.map(&:name).sort
    end

    desc "exec [components] <script>", "Executes the script in the context of a given component or set thereof. " \
                                       "Defaults to all components."
    filter_options dependents: "Run the script on each dependent of a given component",
                   dependencies: "Run the script on each dependency of a given component"
    method_option :concurrency, type: :numeric, aliases: "-c", desc: "Max number of jobs to run concurrently",
                                default: DEFAULT_CONCURRENCY
    method_option :interactive, type: :boolean, default: true, aliases: "-i",
                                desc: "Runs in interactive mode to allow the user to inspect the output of each " \
                                      "component"
    def exec(script_or_components, script = nil)
      CobraCommander::Executor.execute_and_handle_exit(
        runner: ::CobraCommander::Executor::Script.new(script || script_or_components),
        workers: options.concurrency,
        interactive: options.interactive,
        jobs: components_filtered(script && script_or_components)
      )
    end

    desc "cmd [components] <command>", "Executes the command in the context of a given component or set thereof. " \
                                       "Defaults to all components."
    filter_options dependents: "Run the command on each dependent of a given component",
                   dependencies: "Run the command on each dependency of a given component"
    method_option :concurrency, type: :numeric, aliases: "-c", desc: "Max number of jobs to run concurrently",
                                default: DEFAULT_CONCURRENCY
    method_option :interactive, type: :boolean, default: true, aliases: "-i",
                                desc: "Runs in interactive mode to allow the user to inspect the output of each " \
                                      "component"
    def cmd(command_or_components, command = nil)
      CobraCommander::Executor.execute_and_handle_exit(
        runner: ::CobraCommander::Executor::Command.new(command || command_or_components),
        workers: options.concurrency,
        interactive: options.interactive,
        jobs: components_filtered(command && command_or_components).flat_map(&:packages)
      )
    end

    desc "tree [component]", "Prints the dependency tree of a given component or umbrella"
    def tree(component = nil)
      components = component ? [find_component(component)] : umbrella.components
      puts Output::AsciiTree.new(components).to_s
    end

    desc "graph [component]", "Outputs a graph of a given component or umbrella"
    method_option :output, default: File.join(Dir.pwd, "output.dot"), aliases: "-o"
    def graph(component = nil)
      output = File.open(options.output, "w")
      Output::DotGraph.generate(
        component ? [find_component(component)] : umbrella.components,
        output
      )
      puts "Graph generated at #{options.output}"
    rescue ArgumentError => e
      error e.message
    ensure
      output&.close
    end

    desc "changes [--results=RESULTS] [--branch=BRANCH]", "Prints list of changed files"
    method_option :branch, default: "master", aliases: "-b", desc: "Specified target to calculate against"
    def changes
      Output::Change.new(umbrella, options.branch).run!
    end

  private

    def umbrella
      selector = CobraCommander::Source.all.keys.reduce({}) do |sel, key|
        sel.merge(key => options.public_send(key))
      end
      @umbrella ||= CobraCommander::Umbrella.new(options.app, **selector)
    rescue ::CobraCommander::Source::Error => e
      error(e.message)
      exit(1)
    end
  end
end
