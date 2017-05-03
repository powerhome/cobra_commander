# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::Graph do
  describe "#generate!" do
    let(:root) do
      File.expand_path(
        "../..",
        File.dirname(__FILE__)
      )
    end

    let!(:native_graph) do
      graph = GraphViz.new(:G, type: :digraph, concentrate: true)

      # Add 3 nodes
      a = graph.add_nodes("a")
      b = graph.add_nodes("b")
      c = graph.add_nodes("c")

      # Connect b & c to a
      graph.add_edges(a, b)
      graph.add_edges(a, c)

      # Create graph
      graph.output(dot: "native_graph.dot")
    end

    let(:hash_tree) do
      # Hash setup identical to native_graph construction
      {
        name: "a",
        dependencies: [
          {
            name: "b",
            dependencies: [],
          },
          {
            name: "c",
            dependencies: [],
          },
        ],
      }
    end

    before do
      allow_any_instance_of(Cbra::ComponentTree).to receive(:to_h).and_return(hash_tree)
    end

    it "correctly generates graph.dot" do
      Cbra::Graph.new(".", "dot").generate!

      native_dot = File.join(root, "native_graph.dot")
      generated_dot = File.join(root, "graph.dot")

      expect(IO.readlines(native_dot)).to eq(IO.readlines(generated_dot))
    end

    after do
      # Cleanup extra files
      `rm native_graph.dot`
      `rm graph.dot`
    end
  end
end
