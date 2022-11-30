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

      # Builds the given commands in all packages of all components.
      #
      # @param components [Enumerable<CobraCommander::Component>] the target components
      # @param command [String] shell script to run from the directories of the component's packages
      # @return [Array<CobraCommander::Executor::Command>]
      def self.for(components, command)
        components.flat_map(&:packages).map do |package|
          new(package, command)
        end
      end

      # Calls the commands sequentially, stopping ony if an :error happens.
      #
      # If one of the commands skips, the result will be :success.
      #
      # @param commands [Enumerable<CobraCommander::Component>] the target components
      # @return [Array<CobraCommander::Executor::Command>]
      # @see CobraCommander::Executor::Job
      def self.join(commands)
        commands.lazy.map(&:call).reduce do |(_, prev_output), (result, output)|
          new_output = [prev_output&.strip, output&.strip].join("\n")
          return [:error, new_output] if result == :error

          [:success, new_output]
        end
      end

      def initialize(package, command)
        @package = package
        @command = command
      end

      def to_s
        "#{@package.name} (#{@package.key})"
      end

      # @see CobraCommander::Executor::Job
      def call
        command = @package.source.config&.dig("commands", @command)
        case command
        when Array then run_multiple(@package, command)
        when Hash then run_with_criteria(command)
        when nil then skip(format(SKIP_UNEXISTING, @command, @package.key))
        else run_script(command, @package.path)
        end
      end

    private

      def run_with_criteria(command)
        return skip(format(SKIP_CRITERIA, @package.name)) unless match_criteria?(@package, command.fetch("if", {}))

        run_script(command["run"], @package.path)
      end

      def run_multiple(package, commands)
        Command.join(commands.map { |command| Command.new(package, command) })
      end
    end
  end
end
