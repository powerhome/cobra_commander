# frozen_string_literal: true

require "spec_helper"

RSpec.describe "cli", type: :aruba do
  before(:all) { @root = AppHelper.root }

  describe "checking the version" do
    it "reports the current version" do
      run_simple("cobra version", fail_on_error: true)

      expect(last_command_started).to have_output CobraCommander::VERSION
    end
  end

  describe "listing components in the tree" do
    it "outputs the tree of components" do
      run_simple("cobra ls #{@root}", fail_on_error: true)

      expected_output = <<~OUTPUT
        App
        ├── a
        │   ├── b
        │   │   └── g
        │   │       ├── e
        │   │       └── f
        │   └── c
        │       └── b
        │           └── g
        │               ├── e
        │               └── f
        ├── d
        │   ├── b
        │   │   └── g
        │   │       ├── e
        │   │       └── f
        │   └── c
        │       └── b
        │           └── g
        │               ├── e
        │               └── f
        └── node_manifest
            ├── b
            │   └── g
            │       ├── e
            │       └── f
            ├── e
            ├── f
            └── g
                ├── e
                └── f
      OUTPUT

      # This converts a unicode non-breaking space with
      # a normal space because editors.
      expected_output = expected_output.strip.tr("\u00a0", " ")

      expect(last_command_started.output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end
  end

  describe "generating a graph" do
    context "with default format" do
      before do
        run_simple("cobra graph #{@root}", fail_on_error: true)
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
        run_simple("cobra graph #{@root} -f png", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "accepts 'dot'" do
        run_simple("cobra graph #{@root} -f dot", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "rejects everything else" do
        run_simple("cobra graph #{@root} -f pdf", fail_on_error: true)
        expect(last_command_started.output).to_not include("Graph generated")
        expect(last_command_started).to have_output "FORMAT must be 'png' or 'dot'"
      end
    end
  end

  describe "printing changes" do
    context "with defaults (-r test -b master)" do
      before do
        run_simple("cobra changes #{@root}", fail_on_error: true)
      end

      it "does not output 'Test scripts to run' header" do
        expect(last_command_started.output).to_not include("Test scripts to run")
      end
    end

    context "with full results" do
      before do
        run_simple("cobra changes #{@root} -r full", fail_on_error: true)
      end

      it "outputs all headers" do
        expect(last_command_started.output).to include("Changes since last commit on ")
        expect(last_command_started.output).to include("Directly affected components")
        expect(last_command_started.output).to include("Transitively affected components")
        expect(last_command_started.output).to include("Test scripts to run")
      end
    end

    context "with incorrect results specified" do
      it "outputs error message" do
        run_simple("cobra changes #{@root} -r partial", fail_on_error: true)

        expect(last_command_started).to have_output "--results must be 'test', 'full', 'name' or 'json'"
      end
    end

    context "with branch specified" do
      it "outputs specified branch in 'Changes since' header" do
        branch = "origin/master"
        run_simple("cobra changes #{@root} -r full -b #{branch}", fail_on_error: true)

        expect(last_command_started.output).to include("Changes since last commit on #{branch}")
      end
    end

    context "with nonexistent branch specified" do
      it "outputs error message" do
        run_simple("cobra changes #{@root} -b oak_branch", fail_on_error: false)

        expect(last_command_started.output).to include("Specified --branch could not be found")
        expect(last_command_started.output).to_not include("Test scripts to run")
      end
    end
  end
end
