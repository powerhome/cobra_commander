# frozen_string_literal: true

require "thor"

module Cbra
  # Implements the tool's CLI
  class CLI < Thor
    desc "version", "Prints the version"
    def version
      puts Cbra::VERSION
    end
  end
end
