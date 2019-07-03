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
      tree = maybe_cached_tree(options.app, options.cache)
      executor = Executor.new(tree)
      executor.exec(command)
    end

    desc "ls [app_path] #{COMMON_OPTIONS}", "Prints tree of components for an app"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "tree", aliases: "-f", desc: "Format (list or tree, default: list)"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def ls(app_path = nil)
      tree = maybe_cached_tree(app_path || options.app, options.cache)
      Output.print(
        tree,
        options.format
      )
    end

    desc "dependents_of [component] #{COMMON_OPTIONS}", "Outputs count of components in [app] dependent on [component]"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "Path to the root app where the component is mounted"
    method_option :format, default: "count", aliases: "-f", desc: "count or list"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def dependents_of(component)
      tree = maybe_cached_tree(options.app, options.cache)
      dependents = tree.dependents_of(component)
      puts "list" == options.format ? dependents.map(&:name) : dependents.size
    end

    desc "dependencies_of [component] #{COMMON_OPTIONS}", "Outputs a list of components that [component] depends on"
    method_option :app, default: Dir.pwd, aliases: "-a", desc: "App path (default: CWD)"
    method_option :format, default: "list", aliases: "-f", desc: "Format (list or tree, default: list)"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def dependencies_of(component)
      tree = maybe_cached_tree(options.app, options.cache)
      Output.print(
        tree.subtree(component),
        options.format
      )
    end

    desc "version", "Prints version"
    def version
      puts CobraCommander::VERSION
    end

    desc "graph APP_PATH [--format=FORMAT] [--cache=nil]", "Outputs graph"
    method_option :format, default: "png", aliases: "-f", desc: "Accepts png or dot"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def graph(app_path)
      tree = maybe_cached_tree(app_path, options.cache)
      Graph.new(tree, options.format).generate!
    end

    desc "changes APP_PATH [--results=RESULTS] [--branch=BRANCH] [--cache=nil]", "Prints list of changed files"
    method_option :results, default: "test", aliases: "-r", desc: "Accepts test, full, name or json"
    method_option :branch, default: "master", aliases: "-b", desc: "Specified target to calculate against"
    method_option :cache, default: nil, aliases: "-c", desc: CACHE_DESCRIPTION
    def changes(app_path)
      tree = maybe_cached_tree(app_path, options.cache)
      Change.new(tree, options.results, options.branch).run!
    end

    desc "cache APP_PATH CACHE_PATH", "Caches a representation of the component structure of the app"
    def cache(app_path, cache_path)
      tree = CobraCommander.umbrella_tree(app_path)
      write_tree_cache(tree, cache_path)
      puts "Created cache of component tree at #{cache_path}"
    end

  private

    def maybe_cached_tree(app_path, cache_path)
      return CobraCommander.umbrella_tree(app_path) unless cache_path

      if File.exist?(cache_path)
        CobraCommander.tree_from_cache(cache_path)
      else
        tree = CobraCommander.umbrella_tree(app_path)
        write_tree_cache(tree, cache_path)
        tree
      end
    end

    def write_tree_cache(tree, cache_path)
      FileUtils.mkdir_p(File.dirname(cache_path))
      File.write(cache_path, tree.to_json)
    end
  end
end
