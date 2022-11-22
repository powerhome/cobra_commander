# frozen_string_literal: true

require "pastel"
require "tty-spinner"

module CobraCommander
  module Executor
    class Spinners
      pastel = ::Pastel.new
      SPINNER_OPTIONS = {
        format: :bouncing,
        success_mark: pastel.green("[DONE]"),
        error_mark: pastel.red("[ERROR]"),
      }.freeze

      def self.start(execution, output:)
        new(execution, output: output).start
      end

      def initialize(execution, output:)
        @multi = TTY::Spinner::Multi.new(":spinner :task", output: output)
        execution.each { |job, result| register_spinner(job, result) }
      end

      def start
        @multi.top_spinner.update(task: "Running")
        @multi.auto_spin
      end

    private

      def register_spinner(job, result)
        @multi.register(":spinner #{job}", **SPINNER_OPTIONS) do |spinner|
          result.on_fulfillment(spinner) { |_, spin| spin.success }
                .on_rejection(spinner) { |_, spin| spin.error }
        end
      end
    end
  end
end
