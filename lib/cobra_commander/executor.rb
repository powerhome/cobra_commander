# frozen_string_literal: true

require_relative "executor/context"
require_relative "executor/concurrent"

module CobraCommander
  # Execute a command on all given components
  module Executor
    def self.exec(components:, command:, concurrency:, status_output:)
      Concurrent.new(components, concurrency: concurrency, spin_output: status_output)
                .exec(command)
    end
  end
end
