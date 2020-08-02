# frozen_string_literal: true

require "tty-spinner"

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
        multi.register(*spinner(component.name)) do |spin|
          exec.run(command, **options) ? spin.success : spin.error
        end
      end

      def spinner(title)
        pastel = Pastel.new
        [":spinner #{title}", format: :bouncing,
                              success_mark: pastel.green("[DONE]"),
                              error_mark: pastel.red("[ERROR]")]
      end
    end
  end
end
