# frozen_string_literal: true

require "cobra_commander/git_changed"
require "cobra_commander/affected"

module CobraCommander
  class CLI
    module Output
      # Calculates and prints affected components & files
      class Change
        InvalidSelectionError = Class.new(StandardError)

        def initialize(umbrella, oformat, branch, changes: nil)
          @format = oformat
          @branch = branch
          @umbrella = umbrella
          @changes = changes || GitChanged.new(umbrella.path, branch)
        end

        def run!
          assert_valid_result_choice
          if selected_format?("json")
            puts affected.to_json
          else
            show_full if selected_format?("full")
            tests_to_run
          end
        rescue GitChanged::InvalidSelectionError => e
          puts e.message
        end

      private

        def affected
          @affected ||= Affected.new(@umbrella, @changes)
        end

        def show_full
          changes_since_last_commit
          directly_affected_components
          transitively_affected_components
        end

        def assert_valid_result_choice
          return if %w[test full name json].include?(@format)

          raise InvalidSelectionError, "--results must be 'test', 'full', 'name' or 'json'"
        end

        def selected_format?(result)
          @format == result
        end

        def changes_since_last_commit
          puts "<<< Changes since last commit on #{@branch} >>>"
          puts(*@changes) if @changes.any?
          puts blank_line
        end

        def directly_affected_components
          puts "<<< Directly affected components >>>"
          affected.directly.each { |component| puts display(component) }
          puts blank_line
        end

        def transitively_affected_components
          puts "<<< Transitively affected components >>>"
          affected.transitively.each { |component| puts display(component) }
          puts blank_line
        end

        def tests_to_run
          puts "<<< Test scripts to run >>>" if selected_format?("full")
          if selected_format?("name")
            affected.names.each { |component_name| puts component_name }
          else
            affected.scripts.each { |component_script| puts component_script }
          end
        end

        def display(component)
          "#{component.name} - #{component.packages.keys.map(&:to_s).map(&:capitalize).join(' & ')}"
        end

        def blank_line
          ""
        end
      end
    end
  end
end
