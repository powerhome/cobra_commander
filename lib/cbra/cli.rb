# frozen_string_literal: true

require "thor"
require "pp"

module Cbra
  # Implements the tool's CLI
  class CLI < Thor
    desc "ls APP_PATH", "Prints the tree of components for an app"
    def ls(app_path)
      pp ComponentTree.new(app_path).to_h
    end

    desc "version", "Prints the version"
    def version
      puts Cbra::VERSION
    end
  end
end
