# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/affected"

RSpec.describe CobraCommander::Affected do
  let(:umbrella) { CobraCommander.umbrella(AppHelper.root) }

  it "successfully instantiates" do
    expect(CobraCommander::Affected.new(umbrella, [])).to be_truthy
  end

  context "with no changes" do
    let(:no_changes) do
      CobraCommander::Affected.new(umbrella, [])
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
      CobraCommander::Affected.new(umbrella, ["#{umbrella.path}/components/a/Gemfile"])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.directly).to eq(
        [
          {
            name: "a",
            path: ["#{umbrella.path}/components/a"],
            type: "Bundler",
          },
        ]
      )
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.transitively).to eq []
    end

    it "correctly reports test scripts" do
      expect(with_change_to_a.scripts).to eq(["#{umbrella.path}/components/a/test.sh"])
    end

    it "correctly reports component names" do
      expect(with_change_to_a.names).to eq(["a"])
    end
  end

  context "with change to lower level dependency" do
    let(:with_change_to_b) do
      CobraCommander::Affected.new(umbrella, ["#{umbrella.path}/components/b/Gemfile"])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_b.directly).to eq(
        [
          {
            name: "b",
            path: ["#{umbrella.path}/components/b"],
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
            path: ["#{umbrella.path}/components/a"],
            type: "Bundler",
          },
          {
            name: "c",
            path: ["#{umbrella.path}/components/c"],
            type: "Bundler",
          },
          {
            name: "d",
            path: ["#{umbrella.path}/components/d"],
            type: "Bundler",
          },
          {
            name: "node_manifest",
            path: ["#{umbrella.path}/node_manifest"],
            type: "Yarn",
          },
        ]
      )
    end

    it "correctly reports test scripts" do
      expect(with_change_to_b.scripts).to include("#{umbrella.path}/components/a/test.sh")
      expect(with_change_to_b.scripts).to include("#{umbrella.path}/components/b/test.sh")
      expect(with_change_to_b.scripts).to include("#{umbrella.path}/components/c/test.sh")
      expect(with_change_to_b.scripts).to include("#{umbrella.path}/components/d/test.sh")
      expect(with_change_to_b.scripts).to include("#{umbrella.path}/node_manifest/test.sh")
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
      CobraCommander::Affected.new(umbrella, ["#{umbrella.path}/components/f/package.json"])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_f.directly).to eq(
        [
          {
            name: "f",
            path: ["#{umbrella.path}/components/f"],
            type: "Yarn",
          },
        ]
      )
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_f.transitively).to eq(
        [
          {
            name: "a",
            path: ["#{umbrella.path}/components/a"],
            type: "Bundler",
          },
          {
            name: "b",
            path: ["#{umbrella.path}/components/b"],
            type: "Yarn & Bundler",
          },
          {
            name: "c",
            path: ["#{umbrella.path}/components/c"],
            type: "Bundler",
          },
          {
            name: "d",
            path: ["#{umbrella.path}/components/d"],
            type: "Bundler",
          },
          {
            name: "g",
            path: ["#{umbrella.path}/components/g"],
            type: "Yarn",
          },
          {
            name: "h",
            path: ["#{umbrella.path}/components/h"],
            type: "Yarn",
          },
          {
            name: "node_manifest",
            path: ["#{umbrella.path}/node_manifest"],
            type: "Yarn",
          },
        ]
      )
    end

    it "correctly reports test scripts" do
      expect(with_change_to_f.scripts).to include("#{umbrella.path}/components/a/test.sh")
      expect(with_change_to_f.scripts).to include("#{umbrella.path}/components/b/test.sh")
      expect(with_change_to_f.scripts).to include("#{umbrella.path}/components/c/test.sh")
      expect(with_change_to_f.scripts).to include("#{umbrella.path}/components/d/test.sh")
      expect(with_change_to_f.scripts).to_not include("#{umbrella.path}/components/e/test.sh")
      expect(with_change_to_f.scripts).to include("#{umbrella.path}/components/f/test.sh")
      expect(with_change_to_f.scripts).to include("#{umbrella.path}/components/g/test.sh")
      expect(with_change_to_f.scripts).to include("#{umbrella.path}/node_manifest/test.sh")
    end

    it "correctly reports component names" do
      expect(with_change_to_f.names).to include("a")
      expect(with_change_to_f.names).to include("b")
      expect(with_change_to_f.names).to include("c")
      expect(with_change_to_f.names).to include("d")
      expect(with_change_to_f.names).to_not include("e")
      expect(with_change_to_f.names).to include("f")
      expect(with_change_to_f.names).to include("g")
      expect(with_change_to_f.names).to include("node_manifest")
    end
  end
end
