# frozen_string_literal: true

require "pastel"
require "tty-prompt"

module CobraCommander
  module Output
    # Runs an interactive output printer
    class InteractivePrinter
      pastel = Pastel.new
      SUCCESS = "#{pastel.green("✔")} %s"
      ERROR = "#{pastel.red("✖")} %s"
      BYE = pastel.decorate("\n\n👋 Bye!", :white, :on_black, :bold).freeze

      def self.run(contexts, output)
        new(contexts).run(output)
      end

      def initialize(contexts)
        @prompt = TTY::Prompt.new
        @options = contexts.sort(&method(:sort_contexts))
          .reduce({}) do |options, context|
          template = context.success? ? SUCCESS : ERROR
          options.merge format(template, context.component_name) => context
        end
      end

      def run(output)
        loop do
          context = @prompt.select("Print output?", @options)
          output.puts context.output
        end
      rescue TTY::Reader::InputInterrupt
        output.puts BYE
      end

      private

      def sort_contexts(context_a, context_b)
        if context_a.success? == context_b.success?
          context_a.component_name <=> context_b.component_name
        else
          context_a.success? ? 1 : -1
        end
      end
    end
  end
end
