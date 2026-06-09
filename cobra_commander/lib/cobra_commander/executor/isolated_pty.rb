# frozen_string_literal: true

module CobraCommander
  module Executor
    #
    # A PTY-enabled TTY::Command used to execute component scripts.
    #
    # Per-execution environment variables are supplied to TTY::Command#run!
    # (so they are scoped to each subprocess and never mutate the parent
    # ENV), while environment isolation/enhancement such as Bundler's
    # `with_unbundled_env` is contributed by the package sources through
    # their #around_command (see CobraCommander::Ruby::Bundle).
    #
    class IsolatedPTY < ::TTY::Command
      def initialize(**)
        super(pty: true, **)
      end
    end
  end
end
