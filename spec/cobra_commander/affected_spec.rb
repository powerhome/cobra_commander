# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Affected do
  before(:all) do
    @root = AppHelper.root
    @tree = AppHelper.tree
  end

  it "successfully instantiates" do
    expect(described_class.new(@tree, [], @root)).to be_truthy
  end

  context "with no changes" do
    let(:no_changes) do
      described_class.new(@tree, [], @root)
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
      described_class.new(@tree, ["#{@root}/components/a/Gemfile"], @root)
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.directly).to eq(
        [
          {
            name: "a",
            path: "#{@root}/components/a",
            type: "Ruby",
          },
        ]
      )
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.transitively).to eq []
    end

    it "correctly reports test scripts" do
      expect(with_change_to_a.scripts).to eq(["#{@root}/components/a/test.sh"])
    end

    it "correctly reports component names" do
      expect(with_change_to_a.names).to eq(["a"])
    end
  end

  context "with change to lower level dependency" do
    let(:with_change_to_b) do
      described_class.new(@tree, ["#{@root}/components/b/Gemfile"], @root)
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_b.directly).to eq(
        [
          {
            name: "b",
            path: "#{@root}/components/b",
            type: "Ruby & JS",
          },
        ]
      )
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_b.transitively).to eq(
        [
          {
            name: "a",
            path: "#{@root}/components/a",
            type: "Ruby",
          },
          {
            name: "c",
            path: "#{@root}/components/c",
            type: "Ruby",
          },
          {
            name: "d",
            path: "#{@root}/components/d",
            type: "Ruby",
          },
          {
            name: "node_manifest",
            path: "#{@root}/node_manifest",
            type: "JS",
          },
        ]
      )
    end

    it "correctly reports test scripts" do
      expect(with_change_to_b.scripts).to include("#{@root}/components/a/test.sh")
      expect(with_change_to_b.scripts).to include("#{@root}/components/b/test.sh")
      expect(with_change_to_b.scripts).to include("#{@root}/components/c/test.sh")
      expect(with_change_to_b.scripts).to include("#{@root}/components/d/test.sh")
      expect(with_change_to_b.scripts).to include("#{@root}/node_manifest/test.sh")
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
      described_class.new(@tree, ["#{@root}/components/f/package.json"], @root)
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_f.directly).to eq(
        [
          {
            name: "f",
            path: "#{@root}/components/f",
            type: "JS",
          },
        ]
      )
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_f.transitively).to eq(
        [
          {
            name: "a",
            path: "#{@root}/components/a",
            type: "Ruby",
          },
          {
            name: "b",
            path: "#{@root}/components/b",
            type: "Ruby & JS",
          },
          {
            name: "c",
            path: "#{@root}/components/c",
            type: "Ruby",
          },
          {
            name: "d",
            path: "#{@root}/components/d",
            type: "Ruby",
          },
          {
            name: "g",
            path: "#{@root}/components/g",
            type: "JS",
          },
          {
            name: "node_manifest",
            path: "#{@root}/node_manifest",
            type: "JS",
          },
        ]
      )
    end

    it "correctly reports test scripts" do
      expect(with_change_to_f.scripts).to include("#{@root}/components/a/test.sh")
      expect(with_change_to_f.scripts).to include("#{@root}/components/b/test.sh")
      expect(with_change_to_f.scripts).to include("#{@root}/components/c/test.sh")
      expect(with_change_to_f.scripts).to include("#{@root}/components/d/test.sh")
      expect(with_change_to_f.scripts).to_not include("#{@root}/components/e/test.sh")
      expect(with_change_to_f.scripts).to include("#{@root}/components/f/test.sh")
      expect(with_change_to_f.scripts).to include("#{@root}/components/g/test.sh")
      expect(with_change_to_f.scripts).to include("#{@root}/node_manifest/test.sh")
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
