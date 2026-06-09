# frozen_string_literal: true

module CobraCommander
  module Executor
    class Command
      include ::CobraCommander::Executor::PackageCriteria
      include ::CobraCommander::Executor::RunScript

      SKIP_UNEXISTING = "Command %s does not exist. Check your cobra.yml for existing commands in %s."
      SKIP_CRITERIA = "Package %s does not match criteria."

      def initialize(command_name)
        @command_name = command_name
      end

      # Calls the commands sequentially, stopping ony if an :error happens.
      #
      # If one of the commands skips, the result will be :success.
      #
      # @param tty [CobraComander::Executor::IsolatedPTY] tty to execute shell scripts
      # @param package [CobraComander::Package] target package to execute the named command
      # @return [Array<Symbol, String>]
      def call(tty, package)
        package.around_command do |env|
          run_command tty, package, @command_name, env
        end
      end

    private

      def run_command(tty, package, command_name, env)
        definition = package.source.config&.dig("commands", command_name)
        case definition
        when Array then run_multiple(tty, package, definition, env)
        when Hash then run_with_criteria(tty, package, definition, env)
        when nil then [:skip, format(SKIP_UNEXISTING, command_name, package.key)]
        else run_script(tty, definition, package.path, env: env)
        end
      end

      def run_with_criteria(tty, package, command, env)
        return [:skip, format(SKIP_CRITERIA, package.name)] unless match_criteria?(package, command.fetch("if", {}))

        run_script(tty, command["run"], package.path, env: env)
      end

      def run_multiple(tty, package, commands, env)
        run_many(commands) { run_command(tty, package, _1, env) }
      end
    end
  end
end
