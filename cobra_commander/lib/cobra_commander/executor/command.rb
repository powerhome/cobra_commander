# frozen_string_literal: true

require_relative "./job"
require_relative "./package_criteria"

module CobraCommander
  module Executor
    class Command
      include ::CobraCommander::Executor::Job
      include ::CobraCommander::Executor::PackageCriteria

      SKIP_UNEXISTING = "Command %s does not exist. Check your cobra.yml for existing commands in %s."
      SKIP_CRITERIA = "Package %s does not match criteria."

      # Executes the given script in all Components.
      #
      # If a component has two packages in the same path, the script will run only once.
      #
      # @param components [Enumerable<CobraCommander::Component>] the target components
      # @param script [String] shell script to run from the directories of the component's packages
      # @param workers [Integer] number of workers processing the job queue
      # @return [CobraCommander::Executor::Execution]
      # @see .execute
      def self.for(components, command)
        components.flat_map(&:packages).map do |package|
          new(package, command)
        end
      end

      def initialize(package, command)
        @package = package
        @command = command
      end

      def to_s
        "#{@package.name} (#{@package.key})"
      end

      def call
        command = @package.source.config&.dig("commands", @command)
        case command
        when Hash then run_with_criteria command
        when nil then skip(format(SKIP_UNEXISTING, @command, @package.key))
        else run_script command, @package.path
        end
      end

      def run_with_criteria(command)
        return skip(format(SKIP_CRITERIA, @package.name)) unless match_criteria?(@package, command.fetch("if", {}))

        run_script command["run"], @package.path
      end
    end
  end
end
