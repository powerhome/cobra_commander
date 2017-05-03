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

    desc "graph APP_PATH [FORMAT]", "Output graph in desired FORMAT (png or dot), defaults to png"
    def graph(app_path, format = "png")
      Graph.new(app_path, format).generate!
    end

    desc "changes APP_PATH [OPTION] [BRANCH]", "Prints list of changed files - OPTION accepts test or full & defaults to test - BRANCH allows specified target to calculate against & defaults to master"
    def changes(app_path, option = "test", branch = "master")
      Change.new(app_path, option, branch).run!
    end
  end
end
