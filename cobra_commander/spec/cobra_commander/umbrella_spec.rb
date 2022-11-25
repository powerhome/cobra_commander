# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Umbrella do
  let(:umbrella_without_config) { stub_umbrella("modified-app", unpack: true) }
  subject { stub_umbrella("app") }

  describe "configuration" do
    it "is the config file at the root of umbrella" do
      expect(subject.config).to match({
                                      "sources" => {
                                        stub: anything,
                                        memory: anything,
                                      },
                                    })
    end

    it "is empty when the app does not define a config" do
      expect(umbrella_without_config.config).to eql({})
    end

    it "initialize the package sources with their specific configs" do
      umbrella = CobraCommander::Umbrella.new(
        "test", { "sources" => { memory: "memory packages config" } }, memory: true
      )

      expect(umbrella.find("finance").packages.first.source.config).to eql "memory packages config"
    end
  end

  describe "#resolve(component_root_path)" do
    it "resolves a component given the root path" do
      expect(subject.resolve(fixture_file_path("app/finance")).name).to eql "finance"
    end

    it "resolves child paths" do
      expect(subject.resolve(fixture_file_path("app/directory/models/mode.rb")).name).to eql "directory"
    end

    it "is nil when no component was found" do
      expect(subject.resolve("/a/b/c/lol")).to be_nil
    end
  end
end
