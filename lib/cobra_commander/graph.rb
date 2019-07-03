# frozen_string_literal: true

require "graphviz"

module CobraCommander
  # Generates graphs of components
  class Graph
    def initialize(tree, format)
      @format = format
      @tree = tree.to_h
    end

    def generate!
      return unless valid_format?

      g = GraphViz.new(:G, type: :digraph, concentrate: true)

      app_node = g.add_nodes(@tree[:name])
      map_nodes(g, app_node, @tree)
      output(g)
    end

  private

    def map_nodes(g, parent_node, tree)
      tree[:dependencies].each do |dep|
        node = g.find_node(dep[:name]) || g.add_nodes(dep[:name])
        g.add_edges(parent_node, node)
        map_nodes(g, node, dep)
      end
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
