# frozen_string_literal: true

module CobraCommander
  module Executor
    class WorkerPool
      Job = Struct.new(:name, :args) do
        attr_reader :output, :status

        def resolve!(status, output)
          @status = status
          @output = output
        end

        def resolved?
          !@status.nil?
        end
      end

      class Worker
        attr_reader :id

        def initialize(id, pool)
          @id = id
          @pool = pool
        end

        def kill
          @thread&.kill
        end

        def spawn
          @thread = Thread.new do
            loop { break if @pool.run_next == :exit }
          end
        end

        def wait
          @thread.join
        end
      end

      attr_reader :jobs

      def initialize(runner:, workers:, printer:, jobs:, &name_f)
        @tty = ::CobraCommander::Executor::IsolatedPTY.new(printer: printer)
        @runner = runner
        @workers = Array.new(workers) { |id| Worker.new(id, self) }
        @jobs = []
        @queue = Queue.new

        push_all(jobs, &(name_f || :describe))
      end

      def error?
        jobs.map(&:status).any?(:error)
      end

      def push_all(jobs, &name_f)
        jobs.each { push(name_f&.(_1), *Array(_1)) }
      end

      def push(name, *args)
        Job.new(name, args).tap do |job|
          @jobs.push(job)
          @queue.push(job)
        end
      end

      def start
        @stop = false
        @workers.each(&:spawn)
        @queue.close
        begin
          @workers.each(&:wait)
        rescue Interrupt
          @workers.each(&:kill) if @stop
          @stop = true
          retry
        end
      end

      # @private
      def run_next
        return :exit if @stop
        return :exit unless (job = @queue.pop)

        job.resolve!(*@runner.call(@tty, *job.args))
      end
    end
  end
end
