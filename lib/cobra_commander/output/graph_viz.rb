# frozen_string_literal: true

require "graphviz"

module CobraCommander
  module Output
    # Generates graphs of components
    class GraphViz
      def initialize(component)
        @component = component
      end

      def generate!(output)
        g = ::GraphViz.new(:G, type: :digraph, concentrate: true)
        ([@component] + @component.deep_dependencies).each do |component|
          g.add_nodes component.name
          g.add_edges component.name, component.dependencies.map(&:name)
        end

        g.output(extract_format(output) => output)
      end

    private

      def extract_format(output)
        format = output[-3..-1]
        return format if format == "png" || format == "dot"

        raise ArgumentError, "output format must be 'png' or 'dot'"
      end
    end
  end
end
