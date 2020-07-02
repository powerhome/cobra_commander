# frozen_string_literal: true

module CobraCommander
  # Execute commands on all components of a ComponentTree
  class Executor
    def initialize(components)
      @components = components
    end

    def exec(command, printer = $stdout)
      @components.each do |component|
        component.root_paths.each do |path|
          printer.puts "===> #{component.name} (#{path})"
          output, = run_in_component(path, command)
          printer.puts output
        end
      end
    end

  private

    def run_in_component(path, command)
      Dir.chdir(path) do
        Open3.capture2e({}, command)
      end
    end
  end
end
