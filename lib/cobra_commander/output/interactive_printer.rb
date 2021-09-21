# frozen_string_literal: true

require "pastel"
require "tty-prompt"

module CobraCommander
  module Output
    # Runs an interactive output printer
    module InteractivePrinter
      pastel = Pastel.new
      SUCCESS = "#{pastel.green("✔")} %s".freeze
      ERROR = "#{pastel.red("✖")} %s".freeze
      BYE = pastel.decorate("👋 Bye!", :white, :on_black, :bold).freeze

      def self.run(contexts, output)
        prompt = TTY::Prompt.new
        context_options = contexts.reduce({}) do |options, context|
          template = context.success? ? SUCCESS : ERROR
          options.merge(
            format(template, context.component_name) => context
          )
        end
        loop do
          context = prompt.select("Print output?", context_options)
          output.puts context.output
        end
      rescue TTY::Reader::InputInterrupt
        output.puts "\n\n", BYE
      end
    end
  end
end
