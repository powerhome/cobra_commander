# frozen_string_literal: true

require "spec_helper"

RSpec.describe "cobra cli", type: :aruba do
  describe "cobra exec" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra exec -a #{fixture_app} non_existent pwd", fail_on_error: false)

      expect(last_command_started.output).to match(/Component non_existent not found/)
    end

    it "executes the given command on all components" do
      run_command_and_stop("cobra exec -a #{fixture_app} 'basename $PWD'", fail_on_error: true)

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

    it "executes the given command a given component" do
      run_command_and_stop("cobra exec -a #{fixture_app} b 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[b]
    end

    it "executes the given command a given component's dependents" do
      run_command_and_stop("cobra exec -a #{fixture_app} --dependents b 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[a c d f g h node_manifest]
    end

    it "executes the given command a given component's js dependents" do
      run_command_and_stop("cobra exec -a #{fixture_app} --js --dependents b 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[f g h node_manifest]
    end

    it "executes the given command a given component's ruby dependents" do
      run_command_and_stop("cobra exec -a #{fixture_app} --ruby --dependents b 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[a c d h]
    end

    it "executes the given command a given component's dependencies" do
      run_command_and_stop("cobra exec -a #{fixture_app} --dependencies b 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[e]
    end

    it "executes the given command a given component's js dependencies" do
      run_command_and_stop("cobra exec -a #{fixture_app} --js --dependencies h 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[b e f]
    end

    it "executes the given command a given component's ruby dependencies" do
      run_command_and_stop("cobra exec -a #{fixture_app} --ruby --dependencies h 'basename $PWD'", fail_on_error: true)

      expect(last_command_started.output.split("\n").grep(/^[^=]/)).to match_array %w[b]
    end
  end

  describe "cobra graph" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra graph -a #{fixture_app} non_existent", fail_on_error: false)

      expect(last_command_started.output).to match(/Component non_existent not found/)
    end

    context "with default output" do
      before do
        run_command_and_stop("cobra graph -a #{fixture_app}", fail_on_error: true)
      end

      it "outputs explanation" do
        expect(last_command_started.output).to match(%r{Graph generated at #{`pwd`.chomp}.*/output.png})
      end

      it "creates file" do
        expect(exist?("output.png")).to be true
      end
    end

    context "with specified component" do
      it "creates the file" do
        run_command_and_stop("cobra graph -a #{fixture_app} b", fail_on_error: true)
        expect(exist?("output.png")).to be true
      end
    end

    context "with specified output" do
      it "accepts 'png'" do
        run_command_and_stop("cobra graph -a #{fixture_app} -o output.png", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "accepts 'dot'" do
        run_command_and_stop("cobra graph -a #{fixture_app} -o output.dot", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "rejects everything else" do
        run_command_and_stop("cobra graph -a #{fixture_app} -o output.pdf", fail_on_error: false)
        expect(last_command_started.output).to_not include("Graph generated")
        expect(last_command_started).to have_output "output format must be 'png' or 'dot'"
      end
    end
  end

  describe "cobra version" do
    it "reports the current version" do
      run_command_and_stop("cobra version", fail_on_error: true)

      expect(last_command_started).to have_output CobraCommander::VERSION
    end
  end

  describe "cobra tree" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra tree -a #{fixture_app} non_existent", fail_on_error: false)

      expect(last_command_started.output).to match(/Component non_existent not found/)
    end

    it "outputs the tree of components from umbrella when no component is specified" do
      run_command_and_stop("cobra tree -a #{fixture_app}", fail_on_error: true)

      expected_output = <<~OUTPUT
        App
        ├── a
        │   ├── b
        │   │   └── e
        │   └── c
        │       └── b
        │           └── e
        ├── d
        │   ├── b
        │   │   └── e
        │   └── c
        │       └── b
        │           └── e
        ├── h
        │   ├── b
        │   │   └── e
        │   └── f
        │       └── b
        │           └── e
        └── node_manifest
            ├── b
            │   └── e
            ├── e
            ├── f
            │   └── b
            │       └── e
            └── g
                ├── e
                └── f
                    └── b
                        └── e
      OUTPUT

      # This converts a unicode non-breaking space with
      # a normal space because editors.
      expected_output = expected_output.strip.tr("\u00a0", " ")

      expect(last_command_started.output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end

    it "outputs the tree of components from the specified component" do
      run_command_and_stop("cobra tree -a #{fixture_app} a", fail_on_error: true)

      expected_output = <<~OUTPUT
        a
        ├── b
        │   └── e
        └── c
            └── b
                └── e
      OUTPUT

      # This converts a unicode non-breaking space with
      # a normal space because editors.
      expected_output = expected_output.strip.tr("\u00a0", " ")

      expect(last_command_started.output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end
  end

  describe "cobra changes" do
    context "with defaults (-r test -b master)" do
      before do
        run_command_and_stop("cobra changes -a #{fixture_app}", fail_on_error: true)
      end

      it "does not output 'Test scripts to run' header" do
        expect(last_command_started.output).to_not include("Test scripts to run")
      end
    end

    context "with full results" do
      before do
        run_command_and_stop("cobra changes -a #{fixture_app} -r full", fail_on_error: true)
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
        run_command_and_stop("cobra changes -a #{fixture_app} -r partial", fail_on_error: true)

        expect(last_command_started).to have_output "--results must be 'test', 'full', 'name' or 'json'"
      end
    end

    context "with branch specified" do
      it "outputs specified branch in 'Changes since' header" do
        branch = "origin/master"
        run_command_and_stop("cobra changes -a #{fixture_app} -r full -b #{branch}", fail_on_error: true)

        expect(last_command_started.output).to include("Changes since last commit on #{branch}")
      end
    end

    context "with nonexistent branch specified" do
      it "outputs error message" do
        run_command_and_stop("cobra changes -a #{fixture_app} -b oak_branch", fail_on_error: false)

        expect(last_command_started.output).to include("Specified --branch could not be found")
        expect(last_command_started.output).to_not include("Test scripts to run")
      end
    end
  end

  describe "cobra ls" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra ls -a #{fixture_app} non_existent", fail_on_error: false)

      expect(last_command_started.output).to match(/Component non_existent not found/)
    end

    describe "cobra ls component --dependents" do
      it "lists a component's direct dependents" do
        run_command_and_stop("cobra ls -a #{fixture_app} --dependents node_manifest", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match([])
      end

      it "lists a component's transient dependents" do
        run_command_and_stop("cobra ls -a #{fixture_app} --dependents b", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match(%w[a c d f g h node_manifest])
      end

      it "counts a component's transient dependents" do
        run_command_and_stop("cobra ls -a #{fixture_app} --dependents -t b", fail_on_error: true)

        expect(last_command_started.output.to_i).to eq(7)
      end
    end

    describe "cobra ls component --dependencies" do
      it "can list only js dependencies" do
        run_command_and_stop("cobra ls --js --dependencies -a #{fixture_app} h", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match_array %w[b e f]
      end

      it "can list only ruby dependencies" do
        run_command_and_stop("cobra ls --ruby --dependencies -a #{fixture_app} h", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match_array %w[b]
      end

      it "lists a component's direct dependency" do
        run_command_and_stop("cobra ls --dependencies -a #{fixture_app} g", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match_array %w[b e f]
      end

      it "lists a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies -a #{fixture_app} b", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match_array %w[e]
      end

      it "counts a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies -a #{fixture_app} -t h", fail_on_error: true)

        expect(last_command_started.output.strip.to_i).to eq(3)
      end
    end
  end
end
