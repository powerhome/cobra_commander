# frozen_string_literal: true

require "graphviz"

module CobraCommander
  # Generates graphs of components
  class Graph
    def initialize(node, format)
      @format = format
      @node = node
    end

    def generate!
      return unless valid_format?

      g = GraphViz.new(:G, type: :digraph, concentrate: true)
      ([@node] + @node.deep_dependencies).each do |component|
        g.add_nodes component.name
        g.add_edges component.name, component.dependencies.map(&:name)
      end

      output(g)
    end

    def output(g)
      graph = "graph.#{@format}"
      g.output(@format => graph)
      puts "Graph generated at #{`pwd`.chomp}/#{graph}"
    end

    def valid_format?
      return true if @format == "png" || @format == "dot"
      puts "FORMAT must be 'png' or 'dot'"
      false
    end
  end
end
