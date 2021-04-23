# frozen_string_literal: true

require "tty-spinner"
require "stringio"
require "concurrent-ruby"

require_relative "component_exec"

module CobraCommander
  module Executor
    # Execute a command on multiple components
    class MultiExec
      def initialize(components, concurrency:, spin_output: $stderr)
        @components = components
        @multi = TTY::Spinner::Multi.new(":spinner :task", output: spin_output)
        @semaphore = Concurrent::Semaphore.new(concurrency)
      end

      def run(command, output: $stdout, **kwargs)
        buffer = StringIO.new
        @multi.top_spinner.update(task: "Running #{command}")
        @components.each do |component|
          register_job(command: command, component: component,
                       output: buffer, stderr: :stdout,
                       only_output_on_error: true, **kwargs)
        end
        @multi.auto_spin
        output << buffer.string
        @multi.success?
      end

    private

      def pastel
        @pastel ||= Pastel.new
      end

      def spinner_options
        @spinner_options ||= {
          format: :bouncing,
          success_mark: pastel.green("[DONE]"),
          error_mark: pastel.red("[ERROR]"),
        }
      end

      def register_job(component:, command:, **kwargs)
        @multi.register(":spinner #{component.name}", **spinner_options) do |spinner|
          @semaphore.acquire
          exec = ComponentExec.new(component)
          if exec.run(command, **kwargs)
            spinner.success
          else
            spinner.error
          end
          @semaphore.release
        end
      end
    end
  end
end
