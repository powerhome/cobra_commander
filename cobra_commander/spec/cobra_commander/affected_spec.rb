# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/affected"

RSpec.describe CobraCommander::Affected do
  let(:umbrella) { fixture_umbrella("app") }

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
      expect(with_change_to_a.directly.size).to eql 1
      expect(with_change_to_a.directly[0].name).to eql "a"
      expect(with_change_to_a.directly[0].packages.keys).to eql %i[ruby]
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
      expect(with_change_to_b.directly.size).to eql 1
      expect(with_change_to_b.directly[0].name).to eql "b"
      expect(with_change_to_b.directly[0].packages.keys).to eql %i[ruby js]
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_b.transitively.size).to eql 7
      expect(with_change_to_b.transitively[0].name).to eql "a"
      expect(with_change_to_b.transitively[0].packages.keys).to eql %i[ruby]
      expect(with_change_to_b.transitively[1].name).to eql "c"
      expect(with_change_to_b.transitively[1].packages.keys).to eql %i[ruby]
      expect(with_change_to_b.transitively[2].name).to eql "d"
      expect(with_change_to_b.transitively[2].packages.keys).to eql %i[ruby]
      expect(with_change_to_b.transitively[3].name).to eql "f"
      expect(with_change_to_b.transitively[3].packages.keys).to eql %i[js]
      expect(with_change_to_b.transitively[4].name).to eql "g"
      expect(with_change_to_b.transitively[4].packages.keys).to eql %i[js]
      expect(with_change_to_b.transitively[5].name).to eql "h"
      expect(with_change_to_b.transitively[5].packages.keys).to eql %i[ruby js]
      expect(with_change_to_b.transitively[6].name).to eql "node_manifest"
      expect(with_change_to_b.transitively[6].packages.keys).to eql %i[js]
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
      expect(with_change_to_f.directly.size).to eql 1
      expect(with_change_to_f.directly.first.name).to eql "f"
      expect(with_change_to_f.directly.first.packages.keys).to eql %i[js]
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_f.transitively.size).to eql 3
      expect(with_change_to_f.transitively[0].name).to eql "g"
      expect(with_change_to_f.transitively[0].packages.keys).to eql %i[js]
      expect(with_change_to_f.transitively[1].name).to eql "h"
      expect(with_change_to_f.transitively[1].packages.keys).to eql %i[ruby js]
      expect(with_change_to_f.transitively[2].name).to eql "node_manifest"
      expect(with_change_to_f.transitively[2].packages.keys).to eql %i[js]
    end

    it "correctly reports test scripts" do
      expect(with_change_to_f.scripts).to match_array [
        "#{umbrella.path}/components/f/test.sh",
        "#{umbrella.path}/components/g/test.sh",
        "#{umbrella.path}/components/h/test.sh",
        "#{umbrella.path}/node_manifest/test.sh",
      ]
    end

    it "correctly reports component names" do
      expect(with_change_to_f.names).to match_array %w[f g h node_manifest]
    end
  end
end
