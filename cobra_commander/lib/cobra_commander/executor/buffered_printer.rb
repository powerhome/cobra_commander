# frozen_string_literal: true

module CobraCommander
  module Executor
    class BufferedPrinter < TTY::Command::Printers::Null
      TIME_FORMAT = "Finished in %5.3fs"

      def initialize(*)
        super

        @buffers = Hash.new { |h, k| h[k] = StringIO.new }
      end

      def write(cmd, message)
        @buffers[cmd.uuid].write message
      end

      def print_command_out_data(cmd, *args)
        write(cmd, args.join)
      end

      def print_command_err_data(cmd, *args)
        write(cmd, args.join)
      end

      def print_command_start(cmd, *args)
        message = "Running #{decorate(cmd.to_command, :yellow, :bold)} #{args.join(' ')}"
        write(cmd, message)
      end

      def print_command_exit(cmd, status, runtime, *)
        message = TIME_FORMAT % runtime
        message << " with exit status #{status}" if status

        output.puts @buffers.delete(cmd.uuid).string
        output.puts decorate(message, status == 0 ? :green : :red)
        output.puts
      end
    end
  end
end
