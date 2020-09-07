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
        isolate_bundle do
          @component.root_paths.all? do |path|
            tty.run!(command, chdir: path, **cmd_options).success?
          end
        end
      end

    private

      def isolate_bundle(&block)
        if Bundler.respond_to?(:with_unbundled_env)
          Bundler.with_unbundled_env(&block)
        else
          Bundler.with_clean_env(&block)
        end
      end
    end
  end
end
