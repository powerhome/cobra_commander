# frozen_string_literal: true

require "cbra/component_tree"
require "cbra/affected"
require "open3"

module Cbra
  # Calculates and prints affected components & files
  class Change
    InvalidSelectionError = Class.new(StandardError)

    def initialize(path, results, branch)
      @path = path
      @results = results
      @branch = branch
      @tree = ComponentTree.new(path).to_h
      @affected = Affected.new(@tree, changes, path)
    end

    def run!
      assert_valid_result_choice
      Dir.chdir root_dir
      show_full if selected_full_results?
      tests_to_run
    rescue InvalidSelectionError => e
      puts e.message
    end

  private

    def show_full
      changes_since_last_commit
      directly_affected_components
      transitively_affected_components
    end

    def root_dir
      @root_dir ||= `cd "#{@path}" && git rev-parse --show-toplevel`.chomp
    end

    def changes
      @changes ||= begin
        diff, _, result = Open3.capture3("git", "diff", "--name-only", @branch)
        if result.exitstatus == 128
          raise InvalidSelectionError, "Specified --branch could not be found"
        end
        diff.split("\n").map { |f| File.join(root_dir, f) }
      end
    end

    def assert_valid_result_choice
      raise InvalidSelectionError, "--results must be 'test' or 'full'" unless %w[test full].include?(@results)
    end

    def selected_full_results?
      @results == "full"
    end

    def changes_since_last_commit
      puts "<<< Changes since last commit on #{@branch} >>>"
      changes.each { |component| puts component }
      puts blank_line
    end

    def directly_affected_components
      puts "<<< Directly affected components >>>"
      @affected.directly.each { |component| puts component[:name] }
      puts blank_line
    end

    def transitively_affected_components
      puts "<<< Transitively affected components >>>"
      @affected.transitively.each { |component| puts component[:name] }
      puts blank_line
    end

    def tests_to_run
      puts "<<< Test scripts to run >>>"
      @affected.needs_testing.each { |script| puts script }
    end

    def blank_line
      ""
    end
  end
end
