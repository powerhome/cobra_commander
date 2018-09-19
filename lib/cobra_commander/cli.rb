# frozen_string_literal: true

require "thor"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    desc "do [command]", "Executes the command in the context of each component in [app]"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    def do(command)
      tree = CobraCommander.umbrella_tree(options.app)
      executor = Executor.new(tree)
      executor.exec(command)
    end

    desc "ls [app_path]", "Prints tree of components for an app"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "tree", aliases: "-f", desc: "Format (list or tree, default: list)"
    def ls(app_path = nil)
      Output.print(
        CobraCommander.umbrella_tree(app_path || options.app),
        options.format
      )
    end

    desc "dependents_of [component]", "Outputs count of components in [app] dependent on [component]"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "Path to the root app where the component is mounted"
    method_option :format, default: "count", aliases: "-f", desc: "count or list"
    def dependents_of(component)
      dependents = CobraCommander.umbrella_tree(options.app).dependents_of(component)
      puts "list" == options.format ? dependents.map(&:name) : dependents.size
    end

    desc "dependencies_of [component]", "Outputs a list of components that [component] depends on within [app] context"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "list", aliases: "-f", desc: "Format (list or tree, default: list)"
    def dependencies_of(component)
      Output.print(
        CobraCommander.umbrella_tree(options.app).subtree(component),
        options.format
      )
    end

    desc "version", "Prints version"
    def version
      puts CobraCommander::VERSION
    end

    desc "graph APP_PATH [--format=FORMAT]", "Outputs graph"
    method_option :format, default: "png", aliases: "-f", desc: "Accepts png or dot"
    def graph(app_path)
      Graph.new(app_path, options.format).generate!
    end

    desc "changes APP_PATH [--results=RESULTS] [--branch=BRANCH]", "Prints list of changed files"
    method_option :results, default: "test", aliases: "-r", desc: "Accepts test, full, name or json"
    method_option :branch, default: "master", aliases: "-b", desc: "Specified target to calculate against"
    def changes(app_path)
      Change.new(app_path, options.results, options.branch).run!
    end
  end
end
