# frozen_string_literal: true

require "thor"
require "fileutils"

module CobraCommander
  # Implements the tool's CLI
  class CLI < Thor
    CACHE_DESCRIPTION = "Path to a cache file to use (default: nil). If specified, this file will be used to store " \
      "the component tree for the app to speed up subsequent invocations. Must be rotated any time the component " \
      "dependency structure changes."
    COMMON_OPTIONS = "[--app=pwd] [--format=FORMAT] [--cache=nil]"

    desc "do [command] [--app=pwd] [--cache=nil]", "Executes the command in the context of each component in [app]"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def do(command)
      executor = Executor.new(umbrella(options.app).components)
      executor.exec(command)
    end

    desc "ls [app_path] #{COMMON_OPTIONS}", "Prints tree of components for an app"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "tree", aliases: "-f", desc: "Format (list or tree, default: list)"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def ls(app_path = Dir.pwd)
      Output.print(
        umbrella(app_path).root,
        options.format
      )
    end

    desc "dependents_of [component] #{COMMON_OPTIONS}", "Outputs count of components in [app] dependent on [component]"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "Path to the root app where the component is mounted"
    method_option :format, default: "count", aliases: "-f", desc: "count or list"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def dependents_of(component)
      dependents = umbrella(options.app).dependents_of(component)
      return unless dependents
      puts "list" == options.format ? dependents.map(&:name) : dependents.size
    end

    desc "dependencies_of [component] #{COMMON_OPTIONS}", "Outputs a list of components that [component] depends on"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "list", aliases: "-f", desc: "Format (list or tree, default: list)"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
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

    desc "graph APP_PATH [--format=FORMAT] [--cache=nil] [--component]", "Outputs graph"
    method_option :format, default: "png", aliases: "-f", desc: "Accepts png or dot"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def graph(app_path)
      Graph.new(umbrella(app_path).root, options.format).generate!
    end

    desc "changes APP_PATH [--results=RESULTS] [--branch=BRANCH] [--cache=nil]", "Prints list of changed files"
    method_option :results, default: "test", aliases: "-r", desc: "Accepts test, full, name or json"
    method_option :branch, default: "master", aliases: "-b", desc: "Specified target to calculate against"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def changes(app_path)
      Change.new(umbrella(app_path), options.results, options.branch).run!
    end

    desc "cache APP_PATH CACHE_PATH", "Caches a representation of the component structure of the app"
    def cache(app_path, cache_path)
      tree = CobraCommander.umbrella_tree(app_path)
      FileUtils.mkdir_p(File.dirname(cache_path))
      File.write(cache_path, tree.to_json)
      puts "Created cache of component tree at #{cache_path}"
    end

  private

    def umbrella(path)
      CobraCommander.umbrella(path)
    end
  end
end
