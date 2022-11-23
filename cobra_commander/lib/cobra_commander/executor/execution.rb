# frozen_string_literal: true

require "concurrent-ruby"

module CobraCommander
  module Executor
    # A threaded execution environment, limited by the number of given workers
    class Execution < Hash
      #
      # @param jobs [Array<#call>] array of job objects
      # @param workers [Integer] number of workers to process this execution
      # @see CobraCommander::Executor::Job
      def initialize(jobs, workers:)
        super()

        @executor = Concurrent::FixedThreadPool.new(workers, auto_terminate: true)
        merge! create_futures(jobs)
      end

      def wait
        Concurrent::Promises.zip_futures_on(@executor, *values)
                            .tap(&:wait)
      end

    private

      def create_future(job)
        Concurrent::Promises.future_on(@executor, job, &:call).then do |result|
          case result
          in [:error, error]
            Concurrent::Promises.rejected_future(error)
          in [:success, output]
            Concurrent::Promises.fulfilled_future(output)
          else
            Concurrent::Promises.fulfilled_future(result)
          end
        end.flat
      end

      def create_futures(jobs)
        jobs.to_h { |job| [job, create_future(job)] }
      end
    end
  end
end
