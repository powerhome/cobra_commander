# frozen_string_literal: true

require_relative "executor/component_exec"
require_relative "executor/multi_exec"

module CobraCommander
  # Execute commands on all components of a ComponentTree
  module Executor
    def self.exec(components:, command:, concurrency:, output: $stdout, status_output: $stderr)
      components = Array(components)
      exec = if components.size == 1
               ComponentExec.new(components.first)
             else
               MultiExec.new(components, concurrency: concurrency, spin_output: status_output)
             end
      exec.run(command, output: output)
    end
  end
end
