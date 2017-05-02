# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::Graph do
  describe "#generate!" do
    let(:fixture_root) do
      File.expand_path(
        "../fixtures",
        File.dirname(__FILE__)
      )
    end

    let(:root) do
      File.expand_path(
        "../../../cbra",
        File.dirname(__FILE__)
      )
    end

    it "correctly generates graph.dot" do
      Cbra::Graph.new(File.join(fixture_root, "app"), "dot").generate!

      fixture_dot = File.join(fixture_root, "graph.dot")
      generated_dot = File.join(root, "graph.dot")

      expect(IO.readlines(fixture_dot)).to eq(IO.readlines(generated_dot))
    end
  end
end

