# frozen_string_literal: true

require "thor"

module Cbra
  # Implements the tool's CLI
  class CLI < Thor
    desc "ls APP_PATH", "Prints the tree of components for an app"
    def ls(app_path)
      puts FormattedOutput.new(app_path).run!
    end

    desc "version", "Prints the version"
    def version
      puts Cbra::VERSION
    end

    desc "graph APP_PATH", "Outputs graph.png to the current directory"
    def graph(app_path)
      Graph.new(app_path).png
      puts "Graph generated in root directory"
    end
  end
end
