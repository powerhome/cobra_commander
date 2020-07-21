# frozen_string_literal: true

require "spec_helper"

require "securerandom"

RSpec.describe "cobra cli", type: :aruba do
  before(:all) { @root = AppHelper.root }

  describe "cobra do" do
    it "executes the given command on all components" do
      run_command_and_stop("cobra do --app #{@root} 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[
        e
        f
        g
        b
        node_manifest
        h
        a
        c
        d
      ]
    end
  end

  describe "cobra graph" do
    context "with default output" do
      before do
        run_command_and_stop("cobra graph -a #{@root}", fail_on_error: true)
      end

      it "outputs explanation" do
        expect(last_command_started.output).to match /Graph generated at #{`pwd`.chomp}.*\/output.png/
      end

      it "creates file" do
        expect(exist?("output.png")).to be true
      end
    end

    context "with specified component" do
      it "creates the file" do
        run_command_and_stop("cobra graph -a #{@root} b", fail_on_error: true)
        expect(exist?("output.png")).to be true
      end
    end

    context "with specified output" do
      it "accepts 'png'" do
        run_command_and_stop("cobra graph -a #{@root} -o output.png", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "accepts 'dot'" do
        run_command_and_stop("cobra graph -a #{@root} -o output.dot", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "rejects everything else" do
        run_command_and_stop("cobra graph -a #{@root} -o output.pdf", fail_on_error: false)
        expect(last_command_started.output).to_not include("Graph generated")
        expect(last_command_started).to have_output "output format must be 'png' or 'dot'"
      end
    end
  end

  describe "checking the version" do
    it "reports the current version" do
      run_command_and_stop("cobra version", fail_on_error: true)

      expect(last_command_started).to have_output CobraCommander::VERSION
    end
  end

  describe "listing components in the tree" do
    it "outputs the tree of components" do
      run_command_and_stop("cobra ls #{@root}", fail_on_error: true)

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
        ├── h
        │   └── f
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

  describe "printing changes" do
    context "with defaults (-r test -b master)" do
      before do
        run_command_and_stop("cobra changes #{@root}", fail_on_error: true)
      end

      it "does not output 'Test scripts to run' header" do
        expect(last_command_started.output).to_not include("Test scripts to run")
      end
    end

    context "with full results" do
      before do
        run_command_and_stop("cobra changes #{@root} -r full", fail_on_error: true)
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
        run_command_and_stop("cobra changes #{@root} -r partial", fail_on_error: true)

        expect(last_command_started).to have_output "--results must be 'test', 'full', 'name' or 'json'"
      end
    end

    context "with branch specified" do
      it "outputs specified branch in 'Changes since' header" do
        branch = "origin/master"
        run_command_and_stop("cobra changes #{@root} -r full -b #{branch}", fail_on_error: true)

        expect(last_command_started.output).to include("Changes since last commit on #{branch}")
      end
    end

    context "with nonexistent branch specified" do
      it "outputs error message" do
        run_command_and_stop("cobra changes #{@root} -b oak_branch", fail_on_error: false)

        expect(last_command_started.output).to include("Specified --branch could not be found")
        expect(last_command_started.output).to_not include("Test scripts to run")
      end
    end
  end

  describe "fetching dependents of a component in the tree" do
    it "lists a component's direct dependents" do
      run_command_and_stop("cobra dependents_of node_manifest -a #{@root} --format=list", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match([])
    end

    it "lists a component's transient dependents" do
      run_command_and_stop("cobra dependents_of g -a #{@root} --format=list", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match(%w[a b c d node_manifest])
    end

    it "counts a component's transient dependents" do
      run_command_and_stop("cobra dependents_of g -a #{@root} --format=count", fail_on_error: true)

      expect(last_command_started.output.to_i).to eq(5)
    end

    it "doesn't count a component it's not dependent on" do
      run_command_and_stop("cobra dependents_of non_existent -a #{@root} --format=list", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match([])
    end
  end

  describe "dependencies_of" do
    it "counts a component's direct dependency" do
      run_command_and_stop("cobra dependencies_of g -a #{@root}", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match_array %w[e f]
    end

    it "counts a component's transient dependency" do
      run_command_and_stop("cobra dependencies_of b -a #{@root}", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match_array %w[g e f]
    end

    it "finds subtrees that are not the first match" do
      run_command_and_stop("cobra dependencies_of d -a #{@root}", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match_array %w[b g e f c]
    end
  end
end
