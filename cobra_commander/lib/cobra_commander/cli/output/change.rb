# frozen_string_literal: true

require "cobra_commander/git_changed"
require "cobra_commander/affected"

module CobraCommander
  class CLI
    module Output
      class Change
        def initialize(umbrella, branch, changes: nil)
          @branch = branch
          @umbrella = umbrella
          @changes = changes || GitChanged.new(umbrella.path, branch)
        end

        def run!
          print_changes_since_last_commit
          puts
          print_directly_affected_components
          puts
          print_transitively_affected_components
        end

      private

        def affected
          @affected ||= Affected.new(@umbrella, @changes)
        end

        def print_changes_since_last_commit
          puts "<<< Changes since last commit on #{@branch} >>>"
          puts(*@changes) if @changes.any?
        end

        def print_directly_affected_components
          puts "<<< Directly affected components >>>"
          affected.directly.each { |component| display(component) }
        end

        def print_transitively_affected_components
          puts "<<< Transitively affected components >>>"
          affected.transitively.each { |component| display(component) }
        end

        def display(component)
          puts "#{component.name} - #{component.packages.map(&:key).map(&:to_s).map(&:capitalize).join(' & ')}"
        end
      end
    end
  end
end
