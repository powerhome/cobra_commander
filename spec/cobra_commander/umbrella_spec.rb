# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Umbrella do
  subject do
    CobraCommander::Umbrella.new("App", "fake/path").tap do |umbrella|
      umbrella.add_source :test, double(
        path: "a.path",
        dependencies: %w[a b],
        components: [
          { name: "x", path: "/a/b/c/x/x.path", dependencies: %w[b c] },
          { name: "y", path: "/a/b/c/y/y.path", dependencies: [] },
          { name: "z", path: "/a/b/c/z/z.path", dependencies: [] },
        ]
      )
    end
  end

  describe ".resolve(component_root_path)" do
    it "resolves a component given the root path" do
      expect(subject.resolve("/a/b/c/y").name).to eql "y"
    end

    it "is nil when no component was found" do
      expect(subject.resolve("/a/b/c/lol")).to be_nil
    end
  end
end
