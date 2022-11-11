# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/cli/output/dot_graph"

RSpec.describe CobraCommander::CLI::Output::DotGraph do
  describe "#generate!" do
    let(:umbrella) { stub_umbrella("app") }
    let(:expected_dot) { fixture_file("app.dot") }
    let(:generated_dot) { StringIO.new }

    it "correctly generates graph.dot" do
      CobraCommander::CLI::Output::DotGraph.generate(umbrella.components, generated_dot)

      expect(generated_dot.string).to eql expected_dot.read
    end
  end
end
