# frozen_string_literal: true

require "graphviz"

module CobraCommander
  module Output
    # Generates graphs of components
    module GraphViz
      def self.generate(component, output)
        g = ::GraphViz.new(:G, type: :digraph, concentrate: true)
        ([component] + component.deep_dependencies).each do |comp|
          g.add_nodes comp.name
          g.add_edges comp.name, comp.dependencies.map(&:name)
        end

        g.output(extract_format(output) => output)
      end

      private_class_method def self.extract_format(output)
        format = output[-3..-1]
        return format if %w[png dot].include?(format)

        raise ArgumentError, "output format must be 'png' or 'dot'"
      end
    end
  end
end
