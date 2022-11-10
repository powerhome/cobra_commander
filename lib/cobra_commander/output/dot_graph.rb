# frozen_string_literal: true

module CobraCommander
  module Output
    # Generates graphs of components
    module DotGraph
      def self.generate(components, output)
        output << "digraph G {\n"
        [*components, *components.flat_map(&:deep_dependencies)].uniq.each do |comp|
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
