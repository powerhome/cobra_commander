# frozen_string_literal: true

require "tty-command"

module CobraCommander
  module Executor
    # Execute a command on a single component
    class ComponentExec
      def initialize(component)
        @component = component
      end

      def run(command, output: $stdout, **cmd_options)
        tty = TTY::Command.new(pty: true, printer: :quiet, output: output)
        Bundler.with_original_env do
          @component.root_paths.all? do |path|
            tty.run!(command, chdir: path, **cmd_options).success?
          end
        end
      end
    end
  end
end
