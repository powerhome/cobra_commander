# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::ComponentTree do
  context "for the fixture app" do
    let(:fixture_root) do
      File.expand_path(
        "../fixtures",
        File.dirname(__FILE__)
      )
    end

    subject do
      Cbra::ComponentTree.new(
        File.join(fixture_root, "app")
      )
    end

    describe "#to_h" do
      it "provides a nested hash of components" do
        expect(subject.to_h).to eql(
          name: "App",
          dependencies: [
            {
              name: "a",
              dependencies: [
                {
                  name: "b",
                  dependencies: [],
                },
                {
                  name: "c",
                  dependencies: [],
                },
              ],
            },
            {
              name: "d",
              dependencies: [],
            },
          ]
        )
      end
    end
  end
end
