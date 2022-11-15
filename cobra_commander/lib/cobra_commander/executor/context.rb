# frozen_string_literal: true

require "tty-command"

module CobraCommander
  class Executor::Context
    attr_reader :component, :command

    def initialize(component, command)
      @component = component
      @command = command
      @tty = TTY::Command.new(pty: true, printer: :null, stderr: :stdout)
    end

    def results
      @results ||= @component.root_paths.map do |path|
        isolate_bundle do
          @tty.run!(command, chdir: path)
        end
      end
    end

    def component_name
      component.name
    end

    def success?
      results.all?(&:success?)
    end

    def output
      results.join("\n")
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
