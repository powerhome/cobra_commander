# frozen_string_literal: true

require_relative "./job"

module CobraCommander
  module Executor
    class Command
      include ::CobraCommander::Executor::Job

      SKIP_UNEXISTING = "Command %s does not exist. Check your cobra.yml for existing commands in %s."

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
        script = @package.source.config&.dig("commands", @command)
        return skip(format(SKIP_UNEXISTING, @command, @package.key)) unless script

        run_script script, @package.path
      end
    end
  end
end
