# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Graph do
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
      app = graph.add_nodes("App")

      a = graph.add_nodes("a")
      b = graph.add_nodes("b")
      c = graph.add_nodes("c")

      # Connect b & c to a
      graph.add_edges(app, [a, b])
      graph.add_edges(a, b)
      graph.add_edges(a, c)

      # Create graph
      graph.output(dot: "native_graph.dot")
    end

    let(:umbrella) do
      CobraCommander::Umbrella.new("App", "fake/path").tap do |umbrella|
        umbrella.add_source :test, double(
          path: "a.path",
          dependencies: %w[a b],
          components: [
            { name: "a", path: "a.path", dependencies: %w[b c] },
            { name: "b", path: "b.path", dependencies: [] },
            { name: "c", path: "c.path", dependencies: [] },
          ]
        )
      end
    end

    it "correctly generates graph.dot" do
      CobraCommander::Graph.new(umbrella.root, "dot").generate!

      native_dot = File.join(root, "native_graph.dot")
      generated_dot = File.join(root, "graph.dot")

      expect(IO.readlines(native_dot)).to eq(IO.readlines(generated_dot))
    end

    after do
      # Cleanup extra files
      `rm -f native_graph.dot`
      `rm -f graph.dot`
    end
  end
end
