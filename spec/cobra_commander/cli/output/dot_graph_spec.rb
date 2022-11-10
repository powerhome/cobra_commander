# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/cli/output/dot_graph"

RSpec.describe CobraCommander::CLI::Output::DotGraph do
  describe "#generate!" do
    let(:expected_dot) { fixture_file("expected.dot") }
    let(:generated_dot) { StringIO.new }

    let(:umbrella) do
      CobraCommander::Umbrella.new("fake/path").tap do |umbrella|
        umbrella.add_source :test, double(
          packages: [
            double(:package, name: "a", path: "a.path", dependencies: %w[b c]),
            double(:package, name: "b", path: "b.path", dependencies: []),
            double(:package, name: "c", path: "c.path", dependencies: []),
          ]
        )
      end
    end

    it "correctly generates graph.dot" do
      CobraCommander::CLI::Output::DotGraph.generate(umbrella.components, generated_dot)

      expect(generated_dot.string).to eql expected_dot.read
    end

    after do
      `rm -f #{generated_dot}`
    end
  end
end
