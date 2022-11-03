# frozen_string_literal: true

require "spec_helper"

RUBY_2_7 = Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.7.0")

RSpec.describe "cobra cli", type: :aruba do
  let(:umbrella) { fixture_umbrella("app") }
  let(:last_command_output) do
    last_command_started.output.strip.split("\n").grep_v(/warning/).join("\n")
  end

  describe "cobra exec --no-interactive" do
    let(:components_affected) do
      Dir["#{umbrella.path}/{**/**/,}cobra-rocks"].map do |path|
        File.basename File.dirname(path)
      end
    end

    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} non_existent pwd", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
    end

    it "executes the given command on all components" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --no-self 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[
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
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} b 'echo \"hello from\" `pwd`'",
                           fail_on_error: true)

      expect(last_command_output).to include("hello from #{umbrella.path}/components/b")
    end

    it "executes the given command a given component's dependents" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --dependents b 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[a b c d f g h node_manifest]
    end

    it "executes the given command a given component's js dependents" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --js --dependents b 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[b f g h node_manifest]
    end

    it "executes the given command a given component's ruby dependents" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --ruby --dependents b 'touch cobra-rocks'",
                           fail_on_error: false)

      expect(components_affected).to match_array %w[a b c d h]
    end

    it "executes the given command a given component's dependencies" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --dependencies b 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[b e]
    end

    it "executes the given command a given component's js dependencies without self optionally" do
      run_command_and_stop(
        "cobra exec --no-interactive -a #{umbrella.path} --js --dependencies --no-self h 'touch cobra-rocks'",
        fail_on_error: true
      )

      expect(components_affected).to match_array %w[b e f]
    end

    it "executes the given command a given component's js dependencies including own component by default" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --js --dependencies h 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[b e f h]
    end

    it "executes the given command a given component's ruby dependencies" do
      run_command_and_stop(
        "cobra exec --no-interactive -a #{umbrella.path} --ruby --dependencies --no-self h 'echo \"hello from\" `pwd`'",
        fail_on_error: true
      )

      expect(last_command_output).to include("hello from #{umbrella.path}/components/b")
    end
  end

  describe "cobra graph" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra graph -a #{umbrella.path} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
    end

    it "allows overriding the output path" do
      run_command_and_stop("cobra graph -a #{umbrella.path} -o output.dot", fail_on_error: true)
      expect(last_command_output).to match(/Graph generated.*output.dot/)
    end

    context "with default output" do
      before do
        run_command_and_stop("cobra graph -a #{umbrella.path}", fail_on_error: true)
      end

      it "outputs explanation" do
        expect(last_command_output).to match(%r{Graph generated at #{`pwd`.chomp}.*/output.dot})
      end

      it "creates file" do
        expect(exist?("output.dot")).to be true
      end
    end

    context "with specified component" do
      it "creates the file" do
        run_command_and_stop("cobra graph -a #{umbrella.path} b", fail_on_error: true)
        expect(exist?("output.dot")).to be true
      end
    end
  end

  describe "cobra version" do
    it "reports the current version" do
      run_command_and_stop("cobra version", fail_on_error: true)

      expect(last_command_output).to eql CobraCommander::VERSION
    end
  end

  describe "cobra tree" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra tree -a #{umbrella.path} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
    end

    it "outputs the tree of components from umbrella when no component is specified" do
      run_command_and_stop("cobra tree -a #{umbrella.path}", fail_on_error: true)

      expected_output = <<~OUTPUT
        App
        ├── a
        │   ├── b
        │   │   └── e
        │   └── c
        │       └── b
        │           └── e
        ├── b
        │   └── e
        ├── c
        │   └── b
        │       └── e
        ├── d
        │   ├── b
        │   │   └── e
        │   └── c
        │       └── b
        │           └── e
        ├── e
        ├── f
        │   └── b
        │       └── e
        ├── g
        │   ├── e
        │   └── f
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

      expect(last_command_output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end

    it "outputs the tree of components from the specified component" do
      run_command_and_stop("cobra tree -a #{umbrella.path} a", fail_on_error: true)

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

      expect(last_command_output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end
  end

  describe "cobra changes" do
    context "with defaults (-r test -b master)" do
      before do
        run_command_and_stop("cobra changes -a #{umbrella.path}", fail_on_error: true)
      end

      it "does not output 'Test scripts to run' header" do
        expect(last_command_output).to_not include("Test scripts to run")
      end
    end

    context "with full results" do
      before do
        run_command_and_stop("cobra changes -a #{umbrella.path} -r full", fail_on_error: true)
      end

      it "outputs all headers" do
        expect(last_command_output).to include("Changes since last commit on ")
        expect(last_command_output).to include("Directly affected components")
        expect(last_command_output).to include("Transitively affected components")
        expect(last_command_output).to include("Test scripts to run")
      end
    end

    context "with incorrect results specified" do
      it "outputs error message" do
        run_command_and_stop("cobra changes -a #{umbrella.path} -r partial", fail_on_error: false)

        expect(last_command_output).to match "--results must be 'test', 'full', 'name' or 'json'"
      end
    end

    context "with branch specified" do
      it "outputs specified branch in 'Changes since' header" do
        branch = "test-branch"

        run_command_and_stop("cobra changes -a #{umbrella.path} -r full -b #{branch}", fail_on_error: true)

        expect(last_command_output).to include("Changes since last commit on #{branch}")
      end
    end

    context "with nonexistent branch specified" do
      it "outputs error message" do
        run_command_and_stop("cobra changes -a #{umbrella.path} -b oak_branch", fail_on_error: false)

        expect(last_command_output).to include("Specified branch oak_branch could not be found")
        expect(last_command_output).to_not include("Test scripts to run")
      end
    end
  end

  describe "cobra ls" do
    it "lists components affected by changes in a branch" do
      umbrella = fixture_umbrella("modified-app")

      run_command_and_stop("cobra ls -a #{umbrella.path} --affected master", fail_on_error: true)

      expect(last_command_output).to eq("a\nc\nd")
    end

    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra ls -a #{umbrella.path} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found, maybe one of "cobra ls"/)
    end

    it "suggests when there's any DidYouMean match", if: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{umbrella.path} node_manifeast", fail_on_error: false)

      expect(last_command_output).to match(/Component node_manifeast not found, maybe node_manifest, one of "cobra ls"/)
    end

    it "suggests with DidYouMean when one of the list does not exist", if: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{umbrella.path} node_manifeast,a,b", fail_on_error: false)

      expect(last_command_output).to match(/Component node_manifeast not found, maybe node_manifest, one of "cobra ls"/)
    end

    it "has a default suggestion when there isn't DidYouMean", unless: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{umbrella.path} node_manifeast", fail_on_error: false)

      expect(last_command_output).to match(/Component node_manifeast not found, maybe one of "cobra ls"/)
    end

    it "lists a comma separated list of components" do
      run_command_and_stop("cobra ls -a #{umbrella.path} node_manifest,a,b", fail_on_error: false)

      expect(last_command_output.strip.split("\n")).to match(%w[a b node_manifest])
    end

    it "lists components uniquely" do
      run_command_and_stop("cobra ls -a #{umbrella.path} node_manifest,a,a,b,b", fail_on_error: false)

      expect(last_command_output.strip.split("\n")).to match(%w[a b node_manifest])
    end

    describe "cobra ls component --dependents" do
      it "lists a component's direct dependents" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents --no-self node_manifest", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match([])
      end

      it "lists a component's transient dependents" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents --no-self b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[a c d f g h node_manifest])
      end

      it "lists a component itself along with dependents by default" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[a b c d f g h node_manifest])
      end

      it "counts a component's transient dependents" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents -t --no-self b", fail_on_error: true)

        expect(last_command_output.to_i).to eq(7)
      end
    end

    describe "cobra ls component --dependencies" do
      it "can list only js dependencies" do
        run_command_and_stop("cobra ls --js --dependencies --no-self -a #{umbrella.path} h", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[b e f]
      end

      it "can list only ruby dependencies" do
        run_command_and_stop("cobra ls --ruby --dependencies --no-self -a #{umbrella.path} h", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[b]
      end

      it "lists a component's direct dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self -a #{umbrella.path} g", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[b e f]
      end

      it "lists a component itself along with dependents by default" do
        run_command_and_stop("cobra ls --dependencies -a #{umbrella.path} b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[b e])
      end

      it "lists a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self -a #{umbrella.path} b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[e]
      end

      it "counts a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self -a #{umbrella.path} -t h", fail_on_error: true)

        expect(last_command_output.strip.to_i).to eq(3)
      end
    end
  end
end
