# frozen_string_literal: true

module CobraCommander
  module Executor
    #
    # Executes commands in a clean environment, without the influence
    # of the current Bundler env vars.
    #
    class IsolatedPTY < ::TTY::Command
      def initialize(**)
        super(pty: true, **)
      end

      def run!(...)
        isolate_bundle do
          super(...)
        end
      end

      def isolate_bundle(&)
        if Bundler.respond_to?(:with_unbundled_env)
          Bundler.with_unbundled_env(&)
        else
          Bundler.with_clean_env(&)
        end
      end
    end
  end
end
