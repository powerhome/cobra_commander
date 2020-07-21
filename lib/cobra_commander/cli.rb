# frozen_string_literal: true

require "thor"
require "fileutils"

require "cobra_commander"
require "cobra_commander/output/graph_viz"
require "cobra_commander/change"
require "cobra_commander/affected"
require "cobra_commander/output"
require "cobra_commander/executor"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    class_option :app, default: Dir.pwd, aliases: "-a", type: :string

    COMMON_OPTIONS = "[--app=pwd] [--format=FORMAT]"

    desc "do [command] [--app=pwd] [--cache=nil]", "Executes the command in the context of each component in [app]"
    def do(command)
      executor = Executor.new(umbrella(options.app).components)
      executor.exec(command)
    end

    desc "ls [app_path] #{COMMON_OPTIONS}", "Prints tree of components for an app"
    method_option :format, default: "tree", aliases: "-f", desc: "Format (list or tree, default: list)"
    def ls(app_path = Dir.pwd)
      Output.print(
        umbrella(app_path).root,
        options.format
      )
    end

    desc "dependents_of [component] #{COMMON_OPTIONS}", "Outputs count of components in [app] dependent on [component]"
    method_option :format, default: "count", aliases: "-f", desc: "count or list"
    def dependents_of(component)
      dependents = umbrella(options.app).dependents_of(component)
      return unless dependents
      puts "list" == options.format ? dependents.map(&:name) : dependents.size
    end

    desc "dependencies_of [component] #{COMMON_OPTIONS}", "Outputs a list of components that [component] depends on"
    method_option :format, default: "list", aliases: "-f", desc: "Format (list or tree, default: list)"
    def dependencies_of(component)
      Output.print(
        umbrella(options.app).find(component),
        options.format
      )
    end

    desc "version", "Prints version"
    def version
      puts CobraCommander::VERSION
    end

    desc "tree", "Prints the dependency tree of a given component or umbrella"
    def tree(component = nil)
      component = component ? umbrella.find(component) : umbrella.root
      puts CobraCommander::Output::AsciiTree.new(component).to_s
    end

    desc "graph", "Outputs a graph of a given component or umbrella"
    method_option :output, default: File.join(Dir.pwd, "output.png"), aliases: "-o", desc: "Output file, accepts .png or .dot"
    def graph(component = nil)
      component = component ? umbrella.find(component) : umbrella.root
      CobraCommander::Output::GraphViz.new(component).generate!(options.output)
      puts "Graph generated at #{options.output}"
    rescue ArgumentError => error
      error error.message
    end

    desc "changes APP_PATH [--results=RESULTS] [--branch=BRANCH]", "Prints list of changed files"
    method_option :results, default: "test", aliases: "-r", desc: "Accepts test, full, name or json"
    method_option :branch, default: "master", aliases: "-b", desc: "Specified target to calculate against"
    def changes(app_path)
      Change.new(umbrella(app_path), options.results, options.branch).run!
    end

  private

    def umbrella(path = options.app)
      @umbrella ||= CobraCommander.umbrella(path)
    end
  end
end
