# frozen_string_literal: true

require "pastel"
require "tty-prompt"

module CobraCommander
  module Output
    # Prints the given CobraCommander::Executor::Context to [output] collection in markdown
    module MarkdownPrinter
      SUCCESS = "\n## ✔ %s\n".freeze
      ERROR = "\n## ✖ %s\n".freeze
      OUTPUT = "\n```\n$ %s\n\n%s\n```\n".freeze

      def self.run(contexts, output)
        contexts.each do |context|
          template = context.success? ? SUCCESS : ERROR

          output.print format(template, context.component_name)
          output.print format(OUTPUT, context.command, context.output)
        end
      end
    end
  end
end
