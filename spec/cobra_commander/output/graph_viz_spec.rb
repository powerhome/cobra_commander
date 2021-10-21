# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/output/graph_viz"

RSpec.describe CobraCommander::Output::GraphViz do
  describe "#generate!" do
    let(:native_dot) { Tempfile.new(["native_graph", ".dot"]).path }
    let(:generated_dot) { Tempfile.new(["generated_graph", ".dot"]).path }

    let!(:native_graph) do
      graph = ::GraphViz.new(:G, type: :digraph, concentrate: true)

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
      graph.output(dot: native_dot)
    end

    let(:umbrella) do
      CobraCommander::Umbrella.new("App", "fake/path").tap do |umbrella|
        umbrella.add_source :test, double(
          path: "a.path",
          dependencies: %w[a b],
          components: [
            {name: "a", path: "a.path", dependencies: %w[b c]},
            {name: "b", path: "b.path", dependencies: []},
            {name: "c", path: "c.path", dependencies: []}
          ]
        )
      end
    end

    it "correctly generates graph.dot" do
      CobraCommander::Output::GraphViz.generate(umbrella.root, generated_dot)

      expect(IO.readlines(native_dot)).to eq(IO.readlines(generated_dot))
    end

    after do
      `rm -f #{native_dot}`
      `rm -f #{generated_dot}`
    end
  end
end
