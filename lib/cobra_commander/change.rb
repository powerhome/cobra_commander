# frozen_string_literal: true

require "cobra_commander/affected"
require "open3"

module CobraCommander
  # Calculates and prints affected components & files
  class Change
    InvalidSelectionError = Class.new(StandardError)

    def initialize(umbrella, results, branch)
      @root_dir = Dir.chdir(umbrella.path) { `git rev-parse --show-toplevel`.chomp }
      @results = results
      @branch = branch
      @umbrella = umbrella
      @affected = Affected.new(@umbrella, changes)
    end

    def run!
      assert_valid_result_choice
      if selected_result?("json")
        puts @affected.json_representation
      else
        show_full if selected_result?("full")
        tests_to_run
      end
    rescue InvalidSelectionError => e
      puts e.message
    end

    private

    def show_full
      changes_since_last_commit
      directly_affected_components
      transitively_affected_components
    end

    def changes
      @changes ||= begin
        diff, _, result = Dir.chdir(@root_dir) do
          Open3.capture3("git", "diff", "--name-only", @branch)
        end

        raise InvalidSelectionError, "Specified --branch could not be found" if result.exitstatus == 128

        diff.split("\n").map { |f| File.join(@root_dir, f) }
      end
    end

    def assert_valid_result_choice
      return if %w[test full name json].include?(@results)

      raise InvalidSelectionError, "--results must be 'test', 'full', 'name' or 'json'"
    end

    def selected_result?(result)
      @results == result
    end

    def changes_since_last_commit
      puts "<<< Changes since last commit on #{@branch} >>>"
      changes.each { |path| puts path }
      puts blank_line
    end

    def directly_affected_components
      puts "<<< Directly affected components >>>"
      @affected.directly.each { |component| puts display(**component) }
      puts blank_line
    end

    def transitively_affected_components
      puts "<<< Transitively affected components >>>"
      @affected.transitively.each { |component| puts display(**component) }
      puts blank_line
    end

    def tests_to_run
      puts "<<< Test scripts to run >>>" if selected_result?("full")
      if selected_result?("name")
        @affected.names.each { |component_name| puts component_name }
      else
        @affected.scripts.each { |component_script| puts component_script }
      end
    end

    def display(name:, type:, **)
      "#{name} - #{type}"
    end

    def blank_line
      ""
    end
  end
end
