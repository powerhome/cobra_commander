# frozen_string_literal: true

require "cbra/component_tree"

module Cbra
  # Calculates and prints affected components & files
  class Change
    def initialize(path, option, branch)
      @path = path
      @option = option
      @branch = branch
      @tree = ComponentTree.new(path).to_h
    end

    def run!
      return unless valid_option?
      root_dir = `cd "#{@path}" && git rev-parse --show-toplevel`.chomp
      `cd "#{root_dir}"`
      return unless valid_branch?

      changes_since_last_commit(root_dir)
      directly_affected_components
    end

  private

    def changes_since_last_commit(root_dir)
      puts "<<< Changes since last commit on #{@branch} >>>"
      puts blank_line
      @changes = `git diff --name-only #{@branch}`.split("\n").map { |f| File.join(root_dir, f) }
      puts @changes
    end

    def directly_affected_components
      puts blank_line
      puts "<<< Directly affected components >>>"

      directly_affected(@tree)
      puts @directly_affected
    end

    def valid_option?
      return true if @option == "test" || @option == "full"
      puts "OPTION must be 'test' or 'full'"
      false
    end

    def valid_branch?
      # could git fetch --all & parse that if desired.
      # but that fetch takes a LOT more time than git branch.

      # was unable to catch shell error with ruby rescue. So I went this route.
      branches = `git branch`.gsub("* ", "").gsub(" ","").split("\n")
      if branches.include?(@branch)
        return true
      end
      puts "Specified BRANCH does not exist locally"
      false
    end

    def blank_line
      ""
    end

    def directly_affected(parent_component)
      @directly_affected ||= []
      parent_component[:dependencies].each do |component|
        @changes.each do |change|
          @directly_affected << component[:name] if change.start_with?(component[:path])
        end
        directly_affected(component)
      end
      @directly_affected.uniq!
    end
  end
end
