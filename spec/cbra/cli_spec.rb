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
    context "with default format" do
      before do
        run_simple("cbra graph #{fixture_app_path}", fail_on_error: true)
      end

      it "outputs explanation" do
        expect(last_command_started.output).to include("Graph generated at #{`pwd`.chomp}")
      end

      it "creates file" do
        expect(exist?("./graph.png")).to be true
      end
    end

    context "with specified format" do
      it "accepts 'png'" do
        run_simple("cbra graph #{fixture_app_path} -f png", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "accepts 'dot'" do
        run_simple("cbra graph #{fixture_app_path} -f dot", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "rejects everything else" do
        run_simple("cbra graph #{fixture_app_path} -f pdf", fail_on_error: true)
        expect(last_command_started.output).to_not include("Graph generated")
        expect(last_command_started).to have_output "FORMAT must be 'png' or 'dot'"
      end
    end
  end

  describe "printing changes" do
    context "with defaults (-r test -b master)" do
      before do
        run_simple("cbra changes #{fixture_app_path}", fail_on_error: true)
      end

      it "outputs 'Test scripts to run' header" do
        expect(last_command_started.output).to include("Test scripts to run")
      end
    end

    context "with full results" do
      before do
        run_simple("cbra changes #{fixture_app_path} -r full", fail_on_error: true)
      end

      it "outputs all headers" do
        expect(last_command_started.output).to include("Changes since last commit on master")
        expect(last_command_started.output).to include("Directly affected components")
        expect(last_command_started.output).to include("Transitively affected components")
        expect(last_command_started.output).to include("Test scripts to run")
      end
    end
  end
end
