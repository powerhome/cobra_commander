# frozen_string_literal: true

require "spec_helper"

RSpec.describe "cli", type: :aruba do
  let(:fixture_app_path) { "../../spec/fixtures/app" }

  describe "checking the version" do
    it "reports the current version" do
      run_simple("cbra version", fail_on_error: true)

      expect(last_command_started).to have_output Cbra::VERSION
    end
  end

  describe "listing components in the tree" do
    it "outputs the tree of components" do
      run_simple("cbra ls #{fixture_app_path}", fail_on_error: true)

      expect(last_command_started).to have_output <<~OUTPUT
        App
        ├── a
        │   ├── b
        │   └── c
        │       └── b
        └── d
            ├── b
            └── c
                └── b
      OUTPUT
    end
  end

  describe "generating a graph" do
    subject do
      run_simple("cbra graph #{fixture_app_path}", fail_on_error: true)
    end

    it "outputs explanation" do
      subject
      expect(last_command_started).to have_output "Graph generated in root directory"
    end

    it "creates file" do
      subject
      expect(exist?("./graph.png")).to be true
    end
  end
end
