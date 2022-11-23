# frozen_string_literal: true

require "tty-prompt"

module CobraCommander
  module CLI::Output
    # Prints the given CobraCommander::Executor::Context to [output] collection in markdown
    module MarkdownPrinter
      SUCCESS = "\n## ✔ %s\n"
      ERROR = "\n## ✖ %s\n"
      OUTPUT = "\n```\n\n%s\n```\n"

      def self.run(execution, output)
        execution.each do |job, result|
          template = result.fulfilled? ? SUCCESS : ERROR

          output.print format(template, job.name)
          output.print format(OUTPUT, result.fulfilled? ? result.value : result.reason)
        end
      end
    end
  end
end
