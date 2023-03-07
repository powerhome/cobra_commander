# frozen_string_literal: true

module CobraCommander
  module Executor
    # This is a script job. It can target any CobraCommander::Component.
    #
    # Script runs the given script once for each Component#root_paths
    #
    class Script
      include ::CobraCommander::Executor::RunScript

      def initialize(script)
        @script = script
      end

      # Runs the script in the given component
      #
      # It runs the script once for each Component#root_paths. If a component has two packages in the
      # same path, it will run the script only once.
      #
      # @param tty [CobraComander::Executor::IsolatedPTY] tty to execute shell scripts
      # @param component [CobraComander::Component] target component
      # @return [Array<Symbol, String>]
      def call(tty, component)
        run_many(component.root_paths) { run_script(tty, @script, _1) }
      end
    end
  end
end
