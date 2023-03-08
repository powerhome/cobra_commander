# frozen_string_literal: true

module CobraCommander
  module Executor
    module RunScript
      def run_script(tty, script, path)
        result = tty.run!(script, chdir: path, err: :out)

        return [:error, result.out] if result.failed?

        [:success, result.out]
      end

      def run_many(collection, &block)
        collection.lazy.map(&block)
                  .reduce do |(_, prev_output), (result, output)|
          new_output = [prev_output&.strip, output&.strip].join("\n")
          return [:error, new_output] if result == :error

          [:success, new_output]
        end
      end
    end
  end
end
