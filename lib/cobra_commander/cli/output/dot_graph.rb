# frozen_string_literal: true

module CobraCommander
  class CLI
    module Output
      # Generates graphs of components
      module DotGraph
        def self.generate(component, output)
          output << "digraph G {\n"
          ([component] + component.deep_dependencies).each do |comp|
            output << "\t#{comp.name};\n"
            comp.dependencies.each do |dep|
              output << "\t#{comp.name} -> #{dep.name};\n"
            end
          end
          output << "}\n"
        end
      end
    end
  end
end
