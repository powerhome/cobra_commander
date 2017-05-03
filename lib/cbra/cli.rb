# frozen_string_literal: true

require "thor"

module Cbra
  # Implements the tool's CLI
  class CLI < Thor
    desc "ls APP_PATH", "Prints tree of components for an app"
    def ls(app_path)
      puts FormattedOutput.new(app_path).run!
    end

    desc "version", "Prints version"
    def version
      puts Cbra::VERSION
    end

    desc "graph APP_PATH", "Outputs graph"
    method_option :format, default: "png", desc: "Accepts png or dot"
    def graph(app_path)
      Graph.new(app_path, @options[:format]).generate!
    end

    desc "changes APP_PATH", "Prints list of changed files"
    method_option :results, default: "test", desc: "Accepts test or full"
    method_option :branch, default: "master", desc: "Specified target to calculate against"
    def changes(app_path)
      Change.new(app_path, @option[:results], @options[:branch]).run!
    end
  end
end
