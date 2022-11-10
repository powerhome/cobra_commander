# frozen_string_literal: true

require "concurrent-ruby"
require "pastel"
require "tty-spinner"

module CobraCommander
  # Execute a command on all given components
  class Executor
    autoload :Context, "cobra_commander/executor/context"

    def self.exec(components:, command:, concurrency:, status_output:)
      new(components, concurrency: concurrency,
                      spin_output: status_output).exec(command)
    end

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
      @pastel ||= ::Pastel.new
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
