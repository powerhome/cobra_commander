# frozen_string_literal: true

require "tty-prompt"

module CobraCommander
  module Output
    # Prints the given CobraCommander::Executor::Context to [output] collection in markdown
    module MarkdownPrinter
      SUCCESS = "\n## ✔ %s\n"
      ERROR = "\n## ✖ %s\n"
      OUTPUT = "\n```\n$ %s\n\n%s\n```\n"

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
