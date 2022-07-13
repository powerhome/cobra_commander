# frozen_string_literal: true

require "spec_helper"

RUBY_2_7 = Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.7.0")

RSpec.describe "cobra cli", type: :aruba do
  let(:last_command_output) do
    last_command_started.output.strip.split("\n").grep_v(/warning/).join("\n")
  end

  describe "cobra exec --no-interactive" do
    let(:components_affected) do
      Dir["#{fixture_app}/{**/**/,}cobra-rocks"].map(&File.method(:dirname)).map(&File.method(:basename))
    end

    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra exec --no-interactive -a #{fixture_app} non_existent pwd", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
    end

    it "executes the given command on all components" do
      run_command_and_stop("cobra exec --no-interactive -a #{fixture_app} --no-self 'touch cobra-rocks'",
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
      run_command_and_stop("cobra exec --no-interactive -a #{fixture_app} b 'echo \"hello from\" `pwd`'",
                           fail_on_error: true)

      expect(last_command_output).to include("hello from #{fixture_app}/components/b")
    end

    it "executes the given command a given component's dependents" do
      run_command_and_stop("cobra exec --no-interactive -a #{fixture_app} --dependents b 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[a b c d f g h node_manifest]
    end

    it "executes the given command a given component's js dependents" do
      run_command_and_stop("cobra exec --no-interactive -a #{fixture_app} --js --dependents b 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[b f g h node_manifest]
    end

    it "executes the given command a given component's ruby dependents" do
      run_command_and_stop("cobra exec --no-interactive -a #{fixture_app} --ruby --dependents b 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[a b c d h]
    end

    it "executes the given command a given component's dependencies" do
      run_command_and_stop("cobra exec --no-interactive -a #{fixture_app} --dependencies b 'touch cobra-rocks'",
                           fail_on_error: true)

      expect(components_affected).to match_array %w[b e]
    end

    it "executes the given command a given component's js dependencies without self optionally" do
      run_command_and_stop(
        "cobra exec --no-interactive -a #{fixture_app} --js --dependencies --no-self h 'touch cobra-rocks'",
        fail_on_error: true
      )

      expect(components_affected).to match_array %w[b e f]
    end

    it "executes the given command a given component's js dependencies including own component by default" do
      run_command_and_stop(
        "cobra exec --no-interactive -a #{fixture_app} --js --dependencies h 'touch cobra-rocks'",
        fail_on_error: true
      )

      expect(components_affected).to match_array %w[b e f h]
    end

    it "executes the given command a given component's ruby dependencies" do
      run_command_and_stop(
        "cobra exec --no-interactive -a #{fixture_app} --ruby --dependencies --no-self h 'echo \"hello from\" `pwd`'",
        fail_on_error: true
      )

      expect(last_command_output).to include("hello from #{fixture_app}/components/b")
    end
  end

  describe "cobra graph" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra graph -a #{fixture_app} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
    end

    context "with default output" do
      before do
        run_command_and_stop("cobra graph -a #{fixture_app}", fail_on_error: true)
      end

      it "outputs explanation" do
        expect(last_command_output).to match(%r{Graph generated at #{`pwd`.chomp}.*/output.png})
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
        expect(last_command_output).to include("Graph generated")
      end

      it "accepts 'dot'" do
        run_command_and_stop("cobra graph -a #{fixture_app} -o output.dot", fail_on_error: true)
        expect(last_command_output).to include("Graph generated")
      end

      it "rejects everything else" do
        run_command_and_stop("cobra graph -a #{fixture_app} -o output.pdf", fail_on_error: false)
        expect(last_command_output).to_not include("Graph generated")
        expect(last_command_output).to eql "output format must be 'png' or 'dot'"
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
      run_command_and_stop("cobra tree -a #{fixture_app} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
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

      expect(last_command_output.strip.tr("\u00a0", " ")).to eq(expected_output)
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

      expect(last_command_output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end
  end

  describe "cobra changes" do
    context "with defaults (-r test -b master)" do
      before do
        run_command_and_stop("cobra changes -a #{fixture_app}", fail_on_error: true)
      end

      it "does not output 'Test scripts to run' header" do
        expect(last_command_output).to_not include("Test scripts to run")
      end
    end

    context "with full results" do
      before do
        run_command_and_stop("cobra changes -a #{fixture_app} -r full", fail_on_error: true)
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
        run_command_and_stop("cobra changes -a #{fixture_app} -r partial", fail_on_error: true)

        expect(last_command_output).to match "--results must be 'test', 'full', 'name' or 'json'"
      end
    end

    context "with branch specified" do
      it "outputs specified branch in 'Changes since' header" do
        branch = "test-branch"

        run_command_and_stop("cobra changes -a #{fixture_app} -r full -b #{branch}", fail_on_error: true)

        expect(last_command_output).to include("Changes since last commit on #{branch}")
      end
    end

    context "with nonexistent branch specified" do
      it "outputs error message" do
        run_command_and_stop("cobra changes -a #{fixture_app} -b oak_branch", fail_on_error: false)

        expect(last_command_output).to include("Specified --branch could not be found")
        expect(last_command_output).to_not include("Test scripts to run")
      end
    end
  end

  describe "cobra ls" do
    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra ls -a #{fixture_app} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found, maybe one of "cobra ls"/)
    end

    it "suggests when there's any DidYouMean match", if: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{fixture_app} node_manifeast", fail_on_error: false)

      expect(last_command_output).to match(/Component node_manifeast not found, maybe node_manifest, one of "cobra ls"/)
    end

    it "suggests with DidYouMean when one of the list does not exist", if: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{fixture_app} node_manifeast,a,b", fail_on_error: false)

      expect(last_command_output).to match(/Component node_manifeast not found, maybe node_manifest, one of "cobra ls"/)
    end

    it "has a default suggestion when there isn't DidYouMean", unless: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{fixture_app} node_manifest", fail_on_error: false)

      expect(last_command_output).to match(/Component node_manifeast not found, maybe one of "cobra ls"/)
    end

    it "lists a comma separated list of components" do
      run_command_and_stop("cobra ls -a #{fixture_app} node_manifest,a,b", fail_on_error: false)

      expect(last_command_output.strip.split("\n")).to match(%w[a b node_manifest])
    end

    it "lists components uniquely" do
      run_command_and_stop("cobra ls -a #{fixture_app} node_manifest,a,a,b,b", fail_on_error: false)

      expect(last_command_output.strip.split("\n")).to match(%w[a b node_manifest])
    end

    describe "cobra ls component --dependents" do
      it "lists a component's direct dependents" do
        run_command_and_stop("cobra ls -a #{fixture_app} --dependents --no-self node_manifest", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match([])
      end

      it "lists a component's transient dependents" do
        run_command_and_stop("cobra ls -a #{fixture_app} --dependents --no-self b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[a c d f g h node_manifest])
      end

      it "lists a component itself along with dependents by default" do
        run_command_and_stop("cobra ls -a #{fixture_app} --dependents b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[a b c d f g h node_manifest])
      end

      it "counts a component's transient dependents" do
        run_command_and_stop("cobra ls -a #{fixture_app} --dependents -t --no-self b", fail_on_error: true)

        expect(last_command_output.to_i).to eq(7)
      end
    end

    describe "cobra ls component --dependencies" do
      it "can list only js dependencies" do
        run_command_and_stop("cobra ls --js --dependencies --no-self -a #{fixture_app} h", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[b e f]
      end

      it "can list only ruby dependencies" do
        run_command_and_stop("cobra ls --ruby --dependencies --no-self -a #{fixture_app} h", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[b]
      end

      it "lists a component's direct dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self -a #{fixture_app} g", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[b e f]
      end

      it "lists a component itself along with dependents by default" do
        run_command_and_stop("cobra ls --dependencies -a #{fixture_app} b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[b e])
      end

      it "lists a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self -a #{fixture_app} b", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[e]
      end

      it "counts a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self -a #{fixture_app} -t h", fail_on_error: true)

        expect(last_command_output.strip.to_i).to eq(3)
      end
    end
  end
end
