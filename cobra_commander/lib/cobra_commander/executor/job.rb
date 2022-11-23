# frozen_string_literal: true

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
      def error(output)
        [:error, output]
      end

      def success(output)
        [:success, output]
      end
    end
  end
end
