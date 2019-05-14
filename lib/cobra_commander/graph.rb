# frozen_string_literal: true

require "graphviz"
require "cobra_commander/component_tree"

module CobraCommander
  # Generates graphs of components
  class Graph
    def initialize(app_path, format)
      @format = format
      @tree = CobraCommander.umbrella_tree(app_path).to_h
    end

    def generate!
      return unless valid_format?

      g = GraphViz.new(:G, type: :digraph, concentrate: true)
      engines = g.subgraph 'engines'
      gems = g.subgraph 'gems'

      app_node = g.add_nodes(@tree[:name], shape: 'diamond')

      @tree[:dependencies].reject { |dep| dep[:path].match(/engine/) }.each do |dep|
        gems.add_nodes(dep[:name]);
      end

      @tree[:dependencies].select { |dep| dep[:path].match(/engine/) }.each do |dep|
        engines.add_nodes(dep[:name], style: 'filled', shape: 'box');
      end

      map_nodes(g, app_node, @tree)
      output(g)
    end

  private

    def map_nodes(g, parent_node, tree)
      tree[:dependencies].each do |dep|
        node = g.find_node(dep[:name])
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
