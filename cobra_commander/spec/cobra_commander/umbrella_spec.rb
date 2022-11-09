# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Umbrella do
  subject do
    CobraCommander::Umbrella.new("/a/b").tap do |umbrella|
      umbrella.add_source double(
        packages: [
          double(:package, name: "x", path: Pathname.new("/a/b/c/x/x.path"), dependencies: %w[b c]),
          double(:package, name: "y", path: Pathname.new("/a/b/c/y/y.path"), dependencies: []),
          double(:package, name: "z", path: Pathname.new("/a/b/c/z/z.path"), dependencies: []),
        ]
      )
    end
  end

  describe ".resolve(component_root_path)" do
    it "resolves a component given the root path" do
      expect(subject.resolve("/a/b/c/y").name).to eql "y"
    end

    it "resolves child paths" do
      expect(subject.resolve("/a/b/c/z/app/models/mode.rb").name).to eql "z"
    end

    it "is nil when no component was found" do
      expect(subject.resolve("/a/b/c/lol")).to be_nil
    end
  end
end
