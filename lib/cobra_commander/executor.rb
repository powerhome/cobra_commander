# frozen_string_literal: true

require_relative "executor/context"
require_relative "executor/multi_exec"

module CobraCommander
  # Execute a command on all given components
  module Executor
    def self.exec(components:, command:, concurrency:, status_output:)
      components = Array(components)
      MultiExec.new(components, concurrency: concurrency, spin_output: status_output)
               .run(command)
    end
  end
end
