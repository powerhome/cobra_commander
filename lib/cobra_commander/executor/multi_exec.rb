# frozen_string_literal: true

require "tty-spinner"
require "stringio"

require_relative "component_exec"

module CobraCommander
  module Executor
    # Executes a command on multiple components simultaniously
    class MultiExec
      def initialize(components)
        @components = components
      end

      def run(command, output: $stdout, spin_output: $stderr, only_output_on_error: true, **cmd_options)
        cmmd_output = StringIO.new
        multi = TTY::Spinner::Multi.new("Running #{command}", output: spin_output)
        @components.each do |component|
          component_exec(multi, component, command, only_output_on_error: only_output_on_error,
                                                    stderr: :stdout, output: cmmd_output,
                                                    **cmd_options)
        end
        multi.auto_spin
        output << cmmd_output.string
        true
      end

    private

      def component_exec(multi, component, command, **options)
        exec = ComponentExec.new(component)
        pastel = Pastel.new
        multi.register(":spinner #{component.name}",
                       format: :bouncing,
                       success_mark: pastel.green("[DONE]"),
                       error_mark: pastel.red("[ERROR]")) do |spin|
          exec.run(command, **options) ? spin.success : spin.error
        end
      end
    end
  end
end
