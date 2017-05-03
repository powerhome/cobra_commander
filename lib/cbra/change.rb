# frozen_string_literal: true

require "cbra/component_tree"

module Cbra
  # Calculates and prints affected components & files
  class Change
    def initialize(path, option, branch)
      @path = path
      @option = option
      @branch = branch
    end

    def run!
      return unless valid?
    end

  private

    def valid?
      valid_option? && valid_branch?
    end

    def valid_option?
      return true if @option == "test" || @option == "full"
      puts "OPTION must be 'test' or 'full'"
      false
    end

    def valid_branch?
      # check branch exists
      true
    end
  end
end
