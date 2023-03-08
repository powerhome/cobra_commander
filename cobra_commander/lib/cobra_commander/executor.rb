# frozen_string_literal: true

require "pastel"
require "tty-command"
require "tty-prompt"

module CobraCommander
  # Execute a command on all given packages
  module Executor
    autoload :BufferedPrinter, "cobra_commander/executor/buffered_printer"
    autoload :Command, "cobra_commander/executor/command"
    autoload :OutputPrompt, "cobra_commander/executor/output_prompt"
    autoload :IsolatedPTY, "cobra_commander/executor/isolated_pty"
    autoload :PackageCriteria, "cobra_commander/executor/package_criteria"
    autoload :Printers, "cobra_commander/executor/printers"
    autoload :RunScript, "cobra_commander/executor/run_script"
    autoload :Script, "cobra_commander/executor/script"
    autoload :WorkerPool, "cobra_commander/executor/worker_pool"

  module_function

    # Executes the given jobs in an CobraCommander::Executor::WorkerPool.
    #
    # When only one job is queued, it choses the :quiet printer, to print the
    # output as it happens.
    # When more than one job is queued in interactive mode, it uses the :progress
    # printer, which will display a green dot or a red F depending on the result
    # of each script execution.
    # If not in interactive mode, it will print the output in a buffered way to
    # make it easier to read each output.
    #
    # @param jobs [Enumerable<CobraCommander::Executor::Job>] the jobs to run
    # @param interactive [Boolean] prefer interactive output
    # @see CobraCommander::Executor::WorkerPool for more options
    def execute_and_handle_exit(jobs:, interactive: false, **kwargs, &name_f)
      printer = if jobs.size == 1 then :quiet
                elsif interactive then :progress
                else
                  ::CobraCommander::Executor::BufferedPrinter
                end
      pool = WorkerPool.new(jobs: jobs, printer: printer, **kwargs, &name_f).tap(&:start)
      return CobraCommander::Executor::OutputPrompt.run(pool) if interactive && jobs.size > 1

      exit(1) if pool.error?
    end
  end
end
