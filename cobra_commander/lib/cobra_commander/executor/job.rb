# frozen_string_literal: true

require "tty-command"

module CobraCommander
  module Executor
    #
    # This is a helper module to help jobs return valid errors and success outputs.
    #
    # A CobraCommander::Executor::Job is actually any object responding to #call, and returning
    # valid error or success responses.
    #
    # An error is an array containint `:error` and the output (i.e.: [:error, "string output"]).
    # A success is either an array containint `:success` and the output, or just the output
    # (i.e.: [:error, "string output"] or just "string output").
    #
    module Job
      def skip(reason)
        [:skip, reason]
      end

      def error(output)
        [:error, output]
      end

      def success(output)
        [:success, output]
      end

      def run_script(script, path)
        result = isolate_bundle do
          TTY::Command.new(pty: true, printer: :null)
                      .run!(script, chdir: path, err: :out)
        end
        return error(result.out) if result.failed?

        success(result.out)
      end

    private

      def isolate_bundle(&block)
        if Bundler.respond_to?(:with_unbundled_env)
          Bundler.with_unbundled_env(&block)
        else
          Bundler.with_clean_env(&block)
        end
      end
    end
  end
end
