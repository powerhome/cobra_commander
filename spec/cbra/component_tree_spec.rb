# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::ComponentTree do
  context "for the fixture app" do
    let(:app_root) do
      File.expand_path(
        "../fixtures/app",
        File.dirname(__FILE__)
      )
    end

    subject do
      Cbra::ComponentTree.new(app_root)
    end

    describe "#to_h" do
      it "provides a nested hash of components" do
        expect(subject.to_h).to eql(
          name: "App",
          path: app_root,
          dependencies: [
            {
              name: "a",
              path: "#{app_root}/components/a",
              dependencies: [
                {
                  name: "b",
                  path: "#{app_root}/components/b",
                  dependencies: [],
                },
                {
                  name: "c",
                  path: "#{app_root}/components/c",
                  dependencies: [
                    {
                      name: "b",
                      path: "#{app_root}/components/b",
                      dependencies: [],
                    },
                  ],
                },
              ],
            },
            {
              name: "d",
              path: "#{app_root}/components/d",
              dependencies: [
                {
                  name: "b",
                  path: "#{app_root}/components/b",
                  dependencies: [],
                },
                {
                  name: "c",
                  path: "#{app_root}/components/c",
                  dependencies: [
                    {
                      name: "b",
                      path: "#{app_root}/components/b",
                      dependencies: [],
                    },
                  ],
                },
              ],
            },
          ]
        )
      end
    end
  end
end
