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
      valid_results?
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

    def valid_results?
      valid_results = @results == "test" || @results == "full"
      message = "--results must be 'test' or 'full'"
      raise InvalidSelectionError, message unless valid_results
    end

    def selected_full_results?
      @results == "full"
    end

    def changes_since_last_commit
      puts "<<< Changes since last commit on #{@branch} >>>"
      puts changes
      puts blank_line
    end

    def directly_affected_components
      puts "<<< Directly affected components >>>"
      puts(@affected.directly.map { |c| c[:name] })
      puts blank_line
    end

    def transitively_affected_components
      puts "<<< Transitively affected components >>>"
      puts(@affected.transitively.map { |c| c[:name] })
      puts blank_line
    end

    def tests_to_run
      puts "<<< Test scripts to run >>>"
      puts @affected.needing_test_runs
    end

    def blank_line
      ""
    end
  end
end
