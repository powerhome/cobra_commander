# frozen_string_literal: true

require "tty-command"

require_relative "./job"

module CobraCommander
  module Executor
    class Script
      include ::CobraCommander::Executor::Job

      attr_reader :name, :command, :result

      def initialize(name, path, command)
        @name = name
        @command = command
        @path = path
        @tty = TTY::Command.new(pty: true, printer: :null)
      end

      def to_s
        @name
      end

      def call
        isolate_bundle do
          result = @tty.run!(@command, chdir: @path)
          return error(result.err) if result.failed?

          success(result.out)
        end
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
