# frozen_string_literal: true

module CobraCommander
  module Executor
    # Runs an interactive output printer
    class OutputPrompt
      def self.run(pool, output = $stdout)
        new(pool.jobs).run(output)
      end

      pastel = Pastel.new
      ICONS = {
        nil => pastel.dim("⦻"),
        success: pastel.green("✔"),
        skip: pastel.yellow("↷"),
        error: pastel.red("✖"),
      }.freeze
      CANCELLED = pastel.dim("(cancelled)")
      BYE = pastel.bold("\n\n👋 Bye!")

      def initialize(jobs)
        @jobs = jobs
        @prompt = TTY::Prompt.new(symbols: { cross: " " })
      end

      def options
        @options ||= @jobs.map do |job|
          {
            name: format_name(job),
            value: job,
            disabled: !job.resolved? && CANCELLED,
          }
        end
      end

      def run(output)
        return unless @jobs.any?(&:resolved?)

        selected = nil
        output.puts
        loop do
          selected = @prompt.select("Print output?", options, default: format_name(selected))
          output.puts nil, selected.output, nil
        rescue TTY::Reader::InputInterrupt
          output.puts BYE
          break
        end
      end

    private

      def format_name(job)
        return unless job

        "#{ICONS[job.status]} #{job.name}"
      end
    end
  end
end
