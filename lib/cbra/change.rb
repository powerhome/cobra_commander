# frozen_string_literal: true

require "cbra/component_tree"
require "open3"

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
      `cd "#{root_dir}"`
      return unless valid_branch?

      changes_since_last_commit
      calculate_affected(@tree)
      directly_affected_components
      transitively_affected_components
    end

  private

    def root_dir
      @root_dir ||= `cd "#{@path}" && git rev-parse --show-toplevel`.chomp
    end

    def changes
      @changes ||= begin
        `git diff --name-only #{@branch}`.split("\n").map { |f| File.join(root_dir, f) }
      end
    end

    def changes_since_last_commit
      puts "<<< Changes since last commit on #{@branch} >>>"
      puts changes
      puts blank_line
    end

    def directly_affected_components
      puts "<<< Directly affected components >>>"
      puts @directly_affected
      puts blank_line
    end

    def transitively_affected_components
      puts "<<< Transitively affected components >>>"
      puts @transitively_affected
      puts blank_line
    end

    def blank_line; "" end

    def valid_option?
      return true if @option == "test" || @option == "full"
      puts "OPTION must be 'test' or 'full'"
      false
    end

    def valid_branch?
      _, _, result = Open3.capture3("git", "diff", "--name-only", @branch)
      if result.exitstatus == 128
        puts "Specified BRANCH could not be found"
        return false
      end
      true
    end

    def calculate_affected(parent_component)
      define_affected
      find_affected(parent_component)
      cleanup_affected
    end

    def define_affected
      @transitively_affected = []
      @directly_affected = []
    end

    def find_affected(parent_component)
      parent_component[:dependencies].each do |component|
        add_affected(component)
        find_affected(component)
      end
    end

    def add_affected(component)
      changes.each do |change|
        if change.start_with?(component[:path])
          @directly_affected << component[:name]
          @transitively_affected << component[:ancestry]
        end
      end
    end

    def cleanup_affected
      @directly_affected.uniq!
      @transitively_affected.flatten!
      @transitively_affected.uniq!
      @transitively_affected.delete("App")
    end
  end
end
