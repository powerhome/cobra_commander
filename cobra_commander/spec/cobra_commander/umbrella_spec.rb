# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Umbrella do
  subject { stub_umbrella("app") }

  describe ".resolve(component_root_path)" do
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
