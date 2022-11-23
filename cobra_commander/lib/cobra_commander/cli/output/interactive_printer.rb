# frozen_string_literal: true

require "pastel"
require "tty-prompt"

module CobraCommander
  module CLI::Output
    # Runs an interactive output printer
    class InteractivePrinter
      pastel = Pastel.new
      SUCCESS = "#{pastel.green('✔')} %s"
      ERROR = "#{pastel.red('✖')} %s"
      BYE = pastel.decorate("\n\n👋 Bye!", :white, :on_black, :bold).freeze

      def self.run(execution, output)
        new(execution).run(output)
      end

      def initialize(execution)
        @prompt = TTY::Prompt.new
        @execution = execution
      end

      def run(output)
        selected = nil
        loop do
          selected = @prompt.select("Print output?", options, default: options.key(selected))
          output.puts selected.fulfilled? ? selected.value : selected.reason
        end
      rescue TTY::Reader::InputInterrupt
        output.puts BYE
      end

    private

      def options
        @options ||= @execution.sort { |*args| sort_results(*args.flatten) }
                               .reduce({}) do |options, (job, result)|
          template = result.rejected? ? ERROR : SUCCESS
          options.merge format(template, job.to_s) => result
        end
      end

      def sort_results(job_a, result_a, job_b, result_b)
        if result_a.rejected? == result_b.rejected?
          job_a.to_s <=> job_b.to_s
        else
          result_b.rejected? ? 1 : -1
        end
      end
    end
  end
end
