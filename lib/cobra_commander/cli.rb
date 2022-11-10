# frozen_string_literal: true

require "thor"
require "fileutils"
require "concurrent-ruby"

require "cobra_commander"
require "cobra_commander/affected"
require "cobra_commander/git_changed"
require "cobra_commander/executor"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    require_relative "cli/filters"
    require_relative "cli/output/ascii_tree"
    require_relative "cli/output/change"
    require_relative "cli/output/dot_graph"
    require_relative "cli/output/interactive_printer"
    require_relative "cli/output/markdown_printer"

    DEFAULT_CONCURRENCY = (Concurrent.processor_count / 2.0).ceil

    class_option :app, default: Dir.pwd, aliases: "-a", type: :string
    class_option :js, default: false, type: :boolean, desc: "Consider only the JS dependency graph"
    class_option :ruby, default: false, type: :boolean, desc: "Consider only the Ruby dependency graph"

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

    desc "exec [components] <command>", "Executes the command in the context of a given component or set thereof. " \
                                        "Defaults to all components."
    filter_options dependents: "Run the command on each dependent of a given component",
                   dependencies: "Run the command on each dependency of a given component"
    method_option :concurrency, type: :numeric, default: DEFAULT_CONCURRENCY, aliases: "-c",
                                desc: "Max number of jobs to run concurrently"
    method_option :interactive, type: :boolean, default: true, aliases: "-i",
                                desc: "Runs in interactive mode to allow the user to inspect the output of each " \
                                      "component"
    def exec(command_or_components, command = nil)
      results = CobraCommander::Executor.exec(
        components: components_filtered(command && command_or_components),
        command: command || command_or_components,
        concurrency: options.concurrency, status_output: $stderr
      )
      if options.interactive && results.size > 1
        Output::InteractivePrinter.run(results, $stdout)
      else
        Output::MarkdownPrinter.run(results, $stdout)
      end
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
    method_option :results, default: "test", aliases: "-r", desc: "Accepts test, full, name or json"
    method_option :branch, default: "master", aliases: "-b", desc: "Specified target to calculate against"
    def changes
      Output::Change.new(umbrella, options.results, options.branch).run!
    end

  private

    def umbrella
      @umbrella ||= CobraCommander.umbrella(options.app, yarn: options.js, bundler: options.ruby)
    end
  end
end
