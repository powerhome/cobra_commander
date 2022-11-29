# frozen_string_literal: true

require_relative "executor/execution"
require_relative "executor/job"
require_relative "executor/script"
require_relative "executor/command"
require_relative "executor/spinners"
require_relative "executor/interactive_printer"
require_relative "executor/markdown_printer"

module CobraCommander
  # Execute a command on all given packages
  module Executor
  module_function

    # Executes the given jobs in an CobraCommander::Executor::Execution.
    #
    # This facade also allows to execute the jobs with a spinner (@see CobraCommander::Executor::Spinners) to display
    # the execution status of each job.
    #
    # You can also determine how to display the execution once it's completed, by setting `output_mode` to either
    # :interactive or :markdown. When using :interactive, a menu with each job will be displayed allowing the user
    # to select a job and see its output. When using :markdown, a markdown will be printed to `output` with the
    # output of each job.
    #
    # @param jobs [Enumerable<CobraCommander::Executor::Job>] the jobs to run
    # @param status_output [IO,nil] if not nil, will print the spinners for each job in this output
    # @param workers [Integer] number of workers processing the jobs queue (see CobraCommander::Executor::Execution)
    # @param output_mode [:interactive,:markdown,nil] how the output will be printed after execution
    # @param workers [Integer] number of workers processing the jobs queue (see CobraCommander::Executor::Execution)
    # @return [CobraCommander::Executor::Execution]
    # @see CobraCommander::Executor::Execution
    # @see CobraCommander::Executor::Spinners
    # @see CobraCommander::Executor::InterativePrinter
    # @see CobraCommander::Executor::MarkdownPrinter
    def execute(jobs:, status_output: nil, output_mode: nil, output: nil, **kwargs)
      Execution.new(jobs, **kwargs).tap do |execution|
        Spinners.start(execution, output: status_output) if status_output
        execution.wait
        InteractivePrinter.run(execution, output) if output_mode == :interactive
        MarkdownPrinter.run(execution, output) if output_mode == :markdown
      end
    end
  end
end
