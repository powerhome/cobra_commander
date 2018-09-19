# frozen_string_literal: true

module CobraCommander
  class Executor
    def initialize(tree)
      @tree = tree
    end

    def exec(command, printer = $stdout)
      @tree.flatten.each do |component|
        printer.puts "===> #{component.name} (#{component.path})"
        output, _ = run_in_component(component, command)
        printer.puts output
      end
    end
  
  private

    def run_in_component(component, command)
      Dir.chdir(component.path) do
        Open3.capture2e(env_vars(component), command)
      end
    end

    def env_vars(component)
      {"CURRENT_COMPONENT" => component.name, "CURRENT_COMPONENT_PATH" => component.path}
    end
  end
end
