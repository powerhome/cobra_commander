# frozen_string_literal: true

require_relative "executor/execution"
require_relative "executor/job"
require_relative "executor/script"
require_relative "executor/spinners"

module CobraCommander
  # Execute a command on all given packages
  module Executor
  module_function

    # Executes the given jobs, in an Execution
    #
    # @param jobs [Enumerable<CobraCommander::Executor::Job>] the jobs to run
    # @param status_output [IO,nil] if not nil, will print the spinners for each job in this output
    # @param workers [Integer] number of workers processing the jobs queue
    # @return [CobraCommander::Executor::Execution]
    # @see CobraCommander::Executor::Execution
    def execute(jobs:, status_output: nil, **kwargs)
      execution = Execution.new(jobs, **kwargs)
      Spinners.start(execution, output: status_output) if status_output
      execution.tap(&:wait)
    end
  end
end
