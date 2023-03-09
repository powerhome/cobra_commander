# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/affected"

RSpec.describe CobraCommander::Affected do
  let(:umbrella) { stub_umbrella("app") }

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
  end

  context "with change to top level dependency" do
    let(:with_change_to_hr) do
      CobraCommander::Affected.new(umbrella, [umbrella.path.join("hr", "index.html")])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_hr.directly.size).to eql 1
      expect(with_change_to_hr.directly[0].name).to eql "hr"
      expect(with_change_to_hr.directly[0].packages.map(&:key)).to eql %i[stub]
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_hr.transitively).to eq []
    end
  end

  context "with change to lower level dependency" do
    let(:with_change_to_directory) do
      CobraCommander::Affected.new(umbrella, [umbrella.path.join("directory", "index.html")])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_directory.directly.size).to eql 1
      expect(with_change_to_directory.directly[0].name).to eql "directory"
      expect(with_change_to_directory.directly[0].packages.map(&:key)).to eql %i[stub]
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_directory.transitively.size).to eql 3
      expect(with_change_to_directory.transitively[0].name).to eql "finance"
      expect(with_change_to_directory.transitively[0].packages.map(&:key)).to eql %i[stub]
      expect(with_change_to_directory.transitively[1].name).to eql "hr"
      expect(with_change_to_directory.transitively[1].packages.map(&:key)).to eql %i[stub]
      expect(with_change_to_directory.transitively[2].name).to eql "sales"
      expect(with_change_to_directory.transitively[2].packages.map(&:key)).to eql %i[stub]
    end

    it "correctly reports component names" do
      expect(with_change_to_directory.map(&:name)).to match_array %w[directory finance hr sales]
    end
  end

  context "with change to lowest level dependency" do
    let(:with_change_to_auth) do
      CobraCommander::Affected.new(umbrella, [umbrella.path.join("auth", "index.js")])
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_auth.directly.size).to eql 1
      expect(with_change_to_auth.directly.first.name).to eql "auth"
      expect(with_change_to_auth.directly.first.packages.map(&:key)).to eql %i[stub]
    end

    it "correctly reports transitively affected components" do
      expect(with_change_to_auth.transitively.size).to eql 4
      expect(with_change_to_auth.transitively[0].name).to eql "directory"
      expect(with_change_to_auth.transitively[0].packages.map(&:key)).to eql %i[stub]
      expect(with_change_to_auth.transitively[1].name).to eql "finance"
      expect(with_change_to_auth.transitively[1].packages.map(&:key)).to eql %i[stub]
      expect(with_change_to_auth.transitively[2].name).to eql "hr"
      expect(with_change_to_auth.transitively[2].packages.map(&:key)).to eql %i[stub]
      expect(with_change_to_auth.transitively[3].name).to eql "sales"
      expect(with_change_to_auth.transitively[3].packages.map(&:key)).to eql %i[stub]
    end

    it "correctly reports component names" do
      expect(with_change_to_auth.map(&:name)).to match_array %w[auth directory finance hr sales]
    end
  end
end
