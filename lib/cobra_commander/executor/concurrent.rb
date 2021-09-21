# frozen_string_literal: true

require "tty-spinner"
require "concurrent-ruby"

module CobraCommander
  module Executor
    # Execute a command on multiple components concurrently
    class Concurrent
      def initialize(components, concurrency:, spin_output:)
        @components = components
        @multi = TTY::Spinner::Multi.new(":spinner :task", output: spin_output)
        @semaphore = ::Concurrent::Semaphore.new(concurrency)
      end

      def exec(command)
        @multi.top_spinner.update(task: "Running #{command}")
        @results = []
        @components.each do |component|
          register_job(component, command)
        end
        @multi.auto_spin
        @results
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

      def register_job(component, command)
        @multi.register(":spinner #{component.name}", **spinner_options) do |spinner|
          @semaphore.acquire
          context = Context.new(component, command)
          context.success? ? spinner.success : spinner.error
          @results << context
          @semaphore.release
        end
      end
    end
  end
end
