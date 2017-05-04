# frozen_string_literal: true

require "cbra/component_tree"
require "open3"

module Cbra
  # Calculates and prints affected components & files
  class Change
    InvalidBranchError = Class.new(StandardError)

    def initialize(path, option, branch)
      @path = path
      @option = option
      @branch = branch
      @tree = ComponentTree.new(path).to_h
      @transitively_affected = []
      @directly_affected = []
    end

    def run!
      return unless valid_option?
      Dir.chdir root_dir

      if full_output?
        changes_since_last_commit
        calculate_affected(@tree)
        directly_affected_components
        transitively_affected_components
      end

      tests_to_run
    rescue InvalidBranchError => e
      puts e.message
    end

  private

    def root_dir
      @root_dir ||= `cd "#{@path}" && git rev-parse --show-toplevel`.chomp
    end

    def changes
      @changes ||= begin
        diff, _, result = Open3.capture3("git", "diff", "--name-only", @branch)
        if result.exitstatus == 128
          raise InvalidBranchError, "Specified BRANCH could not be found"
        end
        diff.split("\n").map { |f| File.join(root_dir, f) }
      end
    end

    def full_output?
      @option == "full"
    end

    def changes_since_last_commit
      puts "<<< Changes since last commit on #{@branch} >>>"
      puts changes
      puts blank_line
    end

    def directly_affected_components
      puts "<<< Directly affected components >>>"
      puts(@directly_affected.map { |c| c[:name] })
      puts blank_line
    end

    def transitively_affected_components
      puts "<<< Transitively affected components >>>"
      puts(@transitively_affected.map { |c| c[:name] })
      puts blank_line
    end

    def tests_to_run
      puts "<<< Test scripts to run >>>"
      puts all_components_needing_test_runs
    end

    def blank_line
      ""
    end

    def valid_option?
      return true if @option == "test" || @option == "full"
      puts "OPTION must be 'test' or 'full'"
      false
    end

    def calculate_affected(parent_component)
      find_affected(parent_component)
      cleanup_affected
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
          @directly_affected << component.reject { |k| k == :dependencies || k == :ancestry }
          @transitively_affected << component[:ancestry]
        end
      end
    end

    def cleanup_affected
      @directly_affected.uniq!
      @transitively_affected.flatten!
      @transitively_affected.uniq!
      @transitively_affected.delete(name: "App", path: @path)
    end

    def all_components_needing_test_runs
      calculate_affected(@tree) unless @directly_affected && @transitively_affected
      components = (@directly_affected + @transitively_affected).uniq
      components.each_with_object([]) do |component, tests|
        tests << File.join(component[:path], "test.sh")
      end
    end
  end
end
