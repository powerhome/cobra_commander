# frozen_string_literal: true

require "thor"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    desc "ls [app_path]", "Prints tree of components for an app"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "tree", aliases: "-f", desc: "Format (list or tree, default: list)"
    def ls(app_path=nil)
      Output.print(
        umbrella_tree(app_path || options.app),
        options.format
      )
    end

    desc "dependents_of APP_PATH", "Outputs count of components in APP_PATH dependent on COMPONENT"
    method_option :component, required: true, aliases: "-c", desc: "Name of component. Ex: my_component"
    method_option :format, default: "count", aliases: "-f", desc: "count or list"
    def dependents_of(app_path)
      dependents = umbrella_tree(app_path).dependents_of(options.component)
      puts "list" == options.format ? dependents.map(&:name) : dependents.size
    end

    desc "dependencies_of [component]", "Outputs a list of components in APP_PATH that COMPONENT depends on directly or indirectly"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "list", aliases: "-f", desc: "Format (list or tree, default: list)"
    def dependencies_of(component)
      Output.print(
        umbrella_tree(app_path).subtree(component),
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

  private

    def umbrella_tree(path)
      ComponentTree.new(UMBRELLA_APP_NAME, path)
    end
  end
end
