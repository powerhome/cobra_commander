# frozen_string_literal: true

require 'graphviz'
require "cbra/component_tree"
require "pry"

module Cbra
  # Generates graphs of components
  class Graph
    def initialize(app_path)
      @tree = ComponentTree.new(app_path).to_h
    end

    def png
      generate_graph
    end

  private

    def generate_graph
      g = GraphViz.new(:G, type: :digraph, concentrate: true)

      app_node = g.add_nodes(@tree[:name])
      map_nodes(g, app_node, @tree)

      g.output(:png => "graph.png" )
    end

    def map_nodes(g, parent_node, tree)
      tree[:dependencies].each do |dep|
        node = g.find_node(dep[:name]) || g.add_nodes(dep[:name])
        g.add_edges(parent_node, node)
        map_nodes(g, node, dep)
      end
    end
  end
end
