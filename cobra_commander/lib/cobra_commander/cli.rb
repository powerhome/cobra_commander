# frozen_string_literal: true

require "thor"
require "fileutils"
require "concurrent-ruby"

require "cobra_commander"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    require_relative "cli/filters"
    require_relative "cli/output/ascii_tree"
    require_relative "cli/output/change"
    require_relative "cli/output/dot_graph"

    DEFAULT_CONCURRENCY = (Concurrent.processor_count / 2.0).ceil

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
    method_option :concurrency, type: :numeric, default: DEFAULT_CONCURRENCY, aliases: "-c",
                                desc: "Max number of jobs to run concurrently"
    method_option :interactive, type: :boolean, default: true, aliases: "-i",
                                desc: "Runs in interactive mode to allow the user to inspect the output of each " \
                                      "component"
    def exec(script_or_components, script = nil)
      jobs = CobraCommander::Executor::Script.for(
        components_filtered(script && script_or_components),
        script || script_or_components
      )
      CobraCommander::Executor.execute(jobs: jobs, workers: options.concurrency,
                                       output_mode: options.interactive && execution.count > 1 ? :interactive : :markdown,
                                       output: $stdout, status_output: $stderr)
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
      selector = Source.all.keys.reduce({}) do |sel, key|
        sel.merge(key => options.public_send(key))
      end
      @umbrella ||= CobraCommander::Umbrella.new(
        options.app,
        **selector
      )
    rescue ::CobraCommander::Source::Error => e
      error(e.message)
      exit(1)
    end
  end
end
