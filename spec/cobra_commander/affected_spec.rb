# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/affected"

RSpec.describe CobraCommander::Affected do
  it "successfully instantiates" do
    expect(CobraCommander::Affected.new(fixture_umbrella, [])).to be_truthy
  end

  context "with no changes" do
    let(:no_changes) do
      CobraCommander::Affected.new(fixture_umbrella, [])
    end

    it "reports no directly affected components" do
      expect(no_changes.directly).to eq []
    end

    it "reports no transitiely affected components" do
      expect(no_changes.transitively).to eq []
    end

    it "reports no testing needs" do
      expect(no_changes.scripts).to eq []
    end
  end

  context "with change to top level dependency" do
    let(:with_change_to_a) do
      CobraCommander::Affected.new(fixture_umbrella, ["#{fixture_app}/components/a/Gemfile"])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.directly).to eq(
        [
          {
            name: "a",
            path: ["#{fixture_app}/components/a"],
            type: "Bundler",
          },
        ]
      )
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.transitively).to eq []
    end

    it "correctly reports test scripts" do
      expect(with_change_to_a.scripts).to eq(["#{fixture_app}/components/a/test.sh"])
    end

    it "correctly reports component names" do
      expect(with_change_to_a.names).to eq(["a"])
    end
  end

  context "with change to lower level dependency" do
    let(:with_change_to_b) do
      CobraCommander::Affected.new(fixture_umbrella, ["#{fixture_app}/components/b/Gemfile"])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_b.directly).to eq(
        [
          {
            name: "b",
            path: ["#{fixture_app}/components/b"],
            type: "Yarn & Bundler",
          },
        ]
      )
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_b.transitively).to eq(
        [
          {
            name: "a",
            path: ["#{fixture_app}/components/a"],
            type: "Bundler",
          },
          {
            name: "c",
            path: ["#{fixture_app}/components/c"],
            type: "Bundler",
          },
          {
            name: "d",
            path: ["#{fixture_app}/components/d"],
            type: "Bundler",
          },
          {
            name: "f",
            path: ["#{fixture_app}/components/f"],
            type: "Yarn",
          },
          {
            name: "g",
            path: ["#{fixture_app}/components/g"],
            type: "Yarn",
          },
          {
            name: "h",
            path: ["#{fixture_app}/components/h"],
            type: "Yarn & Bundler",
          },
          {
            name: "node_manifest",
            path: ["#{fixture_app}/node_manifest"],
            type: "Yarn",
          },
        ]
      )
    end

    it "correctly reports test scripts" do
      expect(with_change_to_b.scripts).to include("#{fixture_app}/components/a/test.sh")
      expect(with_change_to_b.scripts).to include("#{fixture_app}/components/b/test.sh")
      expect(with_change_to_b.scripts).to include("#{fixture_app}/components/c/test.sh")
      expect(with_change_to_b.scripts).to include("#{fixture_app}/components/d/test.sh")
      expect(with_change_to_b.scripts).to include("#{fixture_app}/node_manifest/test.sh")
    end

    it "correctly reports component names" do
      expect(with_change_to_b.names).to include("a")
      expect(with_change_to_b.names).to include("b")
      expect(with_change_to_b.names).to include("c")
      expect(with_change_to_b.names).to include("d")
      expect(with_change_to_b.names).to include("node_manifest")
    end
  end

  context "with change to lowest level dependency" do
    let(:with_change_to_f) do
      CobraCommander::Affected.new(fixture_umbrella, ["#{fixture_app}/components/f/package.json"])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_f.directly).to eq(
        [
          {
            name: "f",
            path: ["#{fixture_app}/components/f"],
            type: "Yarn",
          },
        ]
      )
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_f.transitively).to eq(
        [
          {
            name: "g",
            path: ["#{fixture_app}/components/g"],
            type: "Yarn",
          },
          {
            name: "h",
            path: ["#{fixture_app}/components/h"],
            type: "Yarn & Bundler",
          },
          {
            name: "node_manifest",
            path: ["#{fixture_app}/node_manifest"],
            type: "Yarn",
          },
        ]
      )
    end

    it "correctly reports test scripts" do
      expect(with_change_to_f.scripts).to match_array [
        "#{fixture_app}/components/f/test.sh",
        "#{fixture_app}/components/g/test.sh",
        "#{fixture_app}/components/h/test.sh",
        "#{fixture_app}/node_manifest/test.sh",
      ]
    end

    it "correctly reports component names" do
      expect(with_change_to_f.names).to match_array %w[f g h node_manifest]
    end
  end
end
