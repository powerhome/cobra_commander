# frozen_string_literal: true

module CobraCommander
  # Execute commands on all components of a ComponentTree
  module Executor
    def self.exec(components, command, printer = $stdout)
      components.each do |component|
        component.root_paths.each do |path|
          printer.puts "===> #{component.name} (#{path})"
          output, = Open3.capture2e(command, chdir: path, unsetenv_others: true)
          printer.puts output
        end
      end
    end
  end
end
