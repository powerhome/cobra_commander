# frozen_string_literal: true

require "spec_helper"

require "securerandom"

RSpec.describe "cli", type: :aruba do
  before(:all) { @root = AppHelper.root }

  describe "checking the version" do
    it "reports the current version" do
      run_command_and_stop("cobra version", fail_on_error: true)

      expect(last_command_started).to have_output CobraCommander::VERSION
    end
  end

  describe "creating a cache" do
    it "saves the dependency structure in JSON format" do
      run_command_and_stop("cobra cache #{@root} tmp/cobra-cache.json", fail_on_error: true)

      expect(exist?("./tmp/cobra-cache.json")).to be true
      expect("./tmp/cobra-cache.json").to have_file_content(
        %({"name":"App","path":"#{@root}","type":"Ruby & JS","ancestry":[],"dependencies":[{"name":"a","path":"#{@root}/components/a","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"}],"dependencies":[{"name":"g","path":"#{@root}/components/g","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[{"name":"e","path":"#{@root}/components/e","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]},{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]}]}]},{"name":"c","path":"#{@root}/components/c","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"}],"dependencies":[{"name":"g","path":"#{@root}/components/g","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[{"name":"e","path":"#{@root}/components/e","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]},{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]}]}]}]}]},{"name":"d","path":"#{@root}/components/d","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"}],"dependencies":[{"name":"g","path":"#{@root}/components/g","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[{"name":"e","path":"#{@root}/components/e","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]},{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]}]}]},{"name":"c","path":"#{@root}/components/c","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"}],"dependencies":[{"name":"g","path":"#{@root}/components/g","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[{"name":"e","path":"#{@root}/components/e","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]},{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]}]}]}]}]},{"name":"h","path":"#{@root}/components/h","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"h","path":"#{@root}/components/h","type":"JS"}],"dependencies":[]}]},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[{"name":"g","path":"#{@root}/components/g","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[{"name":"e","path":"#{@root}/components/e","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]},{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]}]}]},{"name":"e","path":"#{@root}/components/e","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[]},{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[]},{"name":"g","path":"#{@root}/components/g","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[{"name":"e","path":"#{@root}/components/e","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]},{"name":"f","path":"#{@root}/components/f","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"},{"name":"g","path":"#{@root}/components/g","type":"JS"}],"dependencies":[]}]}]}]}) # rubocop:disable Metrics/LineLength
      )
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

    context "from a cache" do
      it "outputs the tree of components" do
        # Generate dependency cache
        cache_file = write_cache(
          %({"name":"App","path":"#{@root}","type":"Ruby & JS","ancestry":[],"dependencies":[{"name":"a","path":"#{@root}/components/a","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}]},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"c","path":"#{@root}/components/c","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[]}]},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[]}]}]}) # rubocop:disable Metrics/LineLength
        )

        # Use cache
        run_command_and_stop("cobra ls #{@root} --cache #{cache_file}", fail_on_error: true)

        expected_output = <<~OUTPUT
          App
          ├── a
          ├── b
          │   └── c
          └── node_manifest
              └── b
        OUTPUT

        # This converts a unicode non-breaking space with
        # a normal space because editors.
        expected_output = expected_output.strip.tr("\u00a0", " ")

        expect(last_command_started.output.strip.tr("\u00a0", " ")).to eq(expected_output)
      end

      context "which is cold" do
        let(:cache_file) { "tmp/#{SecureRandom.uuid}.json" }

        before do
          run_command_and_stop("cobra ls #{@root} --cache #{cache_file}", fail_on_error: false)
        end

        it "outputs the tree of components" do
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

        it "primes the cache" do
          expect(exist?(cache_file)).to be true
          expect(cache_file).to have_file_content(/"name":"App"/)
        end
      end
    end
  end

  describe "generating a graph" do
    context "with default format" do
      before do
        run_command_and_stop("cobra graph #{@root}", fail_on_error: true)
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
        run_command_and_stop("cobra graph #{@root} -f png", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "accepts 'dot'" do
        run_command_and_stop("cobra graph #{@root} -f dot", fail_on_error: true)
        expect(last_command_started.output).to include("Graph generated")
      end

      it "rejects everything else" do
        run_command_and_stop("cobra graph #{@root} -f pdf", fail_on_error: true)
        expect(last_command_started.output).to_not include("Graph generated")
        expect(last_command_started).to have_output "FORMAT must be 'png' or 'dot'"
      end
    end

    context "from a cache" do
      context "which is warm" do
        before do
          cache_file = write_cache(
            %({"name":"App","path":"#{@root}","type":"Ruby & JS","ancestry":[],"dependencies":[{"name":"a","path":"#{@root}/components/a","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}]},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"c","path":"#{@root}/components/c","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[]}]},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[]}]}]}) # rubocop:disable Metrics/LineLength
          )

          run_command_and_stop("cobra graph #{@root} --cache #{cache_file}", fail_on_error: true)
        end

        it "outputs explanation" do
          expect(last_command_started.output).to include("Graph generated at #{`pwd`.chomp}")
        end

        it "creates file" do
          expect(exist?("./graph.png")).to be true
        end
      end

      context "which is cold" do
        let(:cache_file) { "tmp/#{SecureRandom.uuid}.json" }

        before do
          run_command_and_stop("cobra graph #{@root} --cache #{cache_file}", fail_on_error: true)
        end

        it "outputs explanation" do
          expect(last_command_started.output).to include("Graph generated at #{`pwd`.chomp}")
        end

        it "creates file" do
          expect(exist?("./graph.png")).to be true
        end

        it "primes the cache" do
          expect(exist?(cache_file)).to be true
          expect(cache_file).to have_file_content(/"name":"App"/)
        end
      end
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

    context "from a cache" do
      context "which is warm" do
        context "with full results" do
          before do
            cache_file = write_cache(
              %({"name":"App","path":"#{@root}","type":"Ruby & JS","ancestry":[],"dependencies":[{"name":"a","path":"#{@root}/components/a","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}]},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"c","path":"#{@root}/components/c","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[]}]},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[]}]}]}) # rubocop:disable Metrics/LineLength
            )
            run_command_and_stop("cobra changes #{@root} -r full --cache #{cache_file}", fail_on_error: true)
          end

          it "outputs all headers" do
            expect(last_command_started.output).to include("Changes since last commit on ")
            expect(last_command_started.output).to include("Directly affected components")
            expect(last_command_started.output).to include("Transitively affected components")
            expect(last_command_started.output).to include("Test scripts to run")
          end
        end
      end

      context "which is cold" do
        let(:cache_file) { "tmp/#{SecureRandom.uuid}.json" }

        context "with full results" do
          before do
            run_command_and_stop("cobra changes #{@root} -r full --cache #{cache_file}", fail_on_error: true)
          end

          it "outputs all headers" do
            expect(last_command_started.output).to include("Changes since last commit on ")
            expect(last_command_started.output).to include("Directly affected components")
            expect(last_command_started.output).to include("Transitively affected components")
            expect(last_command_started.output).to include("Test scripts to run")
          end

          it "primes the cache" do
            expect(exist?(cache_file)).to be true
            expect(cache_file).to have_file_content(/"name":"App"/)
          end
        end
      end
    end
  end

  describe "fetching dependents of a component in the tree" do
    it "lists a component's direct dependents" do
      run_command_and_stop("cobra dependents_of node_manifest -a #{@root} --format=list", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match(["App"])
    end

    it "lists a component's transient dependents" do
      run_command_and_stop("cobra dependents_of g -a #{@root} --format=list", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match(%w[App a b c d node_manifest])
    end

    it "counts a component's transient dependents" do
      run_command_and_stop("cobra dependents_of g -a #{@root} --format=count", fail_on_error: true)

      expect(last_command_started.output.to_i).to eq(6)
    end

    it "doesn't count a component it's not dependent on" do
      run_command_and_stop("cobra dependents_of non_existent -a #{@root} --format=list", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match([])
    end

    context "from a cache" do
      it "lists a component's dependents" do
        cache_file = write_cache(
          %({"name":"App","path":"#{@root}","type":"Ruby & JS","ancestry":[],"dependencies":[{"name":"a","path":"#{@root}/components/a","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}]},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"c","path":"#{@root}/components/c","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[]}]},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[]}]}]}) # rubocop:disable Metrics/LineLength
        )

        run_command_and_stop("cobra dependents_of c -a #{@root} --format=list --cache #{cache_file}", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match(%w[App b])
      end

      context "which is cold" do
        let(:cache_file) { "tmp/#{SecureRandom.uuid}.json" }

        before do
          run_command_and_stop("cobra dependents_of c -a #{@root} --format=list --cache #{cache_file}", fail_on_error: true)
        end

        it "lists a component's dependents" do
          expect(last_command_started.output.strip.split("\n")).to match(%w[App a d])
        end

        it "primes the cache" do
          expect(exist?(cache_file)).to be true
          expect(cache_file).to have_file_content(/"name":"App"/)
        end
      end
    end
  end

  describe "dependencies_of" do
    it "counts a component's direct dependency" do
      run_command_and_stop("cobra dependencies_of g -a #{@root}", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match(%w[e f])
    end

    it "counts a component's transient dependency" do
      run_command_and_stop("cobra dependencies_of b -a #{@root}", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match(%w[g e f])
    end

    it "finds subtrees that are not the first match" do
      run_command_and_stop("cobra dependencies_of d -a #{@root}", fail_on_error: true)

      expect(last_command_started.output.strip.split("\n")).to match(%w[b g e f c])
    end

    context "from a cache" do
      it "lists a component's direct dependency" do
        cache_file = write_cache(
          %({"name":"App","path":"#{@root}","type":"Ruby & JS","ancestry":[],"dependencies":[{"name":"a","path":"#{@root}/components/a","type":"Ruby","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}]},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"c","path":"#{@root}/components/c","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"}],"dependencies":[]}]},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"}],"dependencies":[{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS","ancestry":[{"name":"App","path":"#{@root}","type":"Ruby & JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"dependencies":[]}]}]}) # rubocop:disable Metrics/LineLength
        )

        run_command_and_stop("cobra dependencies_of b -a #{@root} --cache #{cache_file}", fail_on_error: true)

        expect(last_command_started.output.strip.split("\n")).to match(%w[c])
      end
    end

    context "which is cold" do
      let(:cache_file) { "tmp/#{SecureRandom.uuid}.json" }

      before do
        run_command_and_stop("cobra dependencies_of b -a #{@root} --cache #{cache_file}", fail_on_error: true)
      end

      it "lists a component's direct dependency" do
        expect(last_command_started.output.strip.split("\n")).to match(%w[g e f])
      end

      it "primes the cache" do
        expect(exist?(cache_file)).to be true
        expect(cache_file).to have_file_content(/"name":"App"/)
      end
    end
  end

  def write_cache(contents)
    tempfile = Tempfile.new
    tempfile.write(contents)
    tempfile.rewind
    tempfile.path
  end
end
