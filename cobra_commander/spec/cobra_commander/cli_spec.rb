# frozen_string_literal: true

require "spec_helper"

RUBY_2_7 = Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.7.0")

RSpec.describe "cobra cli", type: :aruba do
  let(:last_command_output) do
    last_command_started.output.strip.split("\n").grep_v(/warning/).join("\n")
  end

  describe "cobra exec --no-interactive" do
    let(:umbrella) { stub_umbrella("app") }

    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} non_existent pwd", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
    end

    it "executes the given command on all components" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --no-self 'echo \"hi\" `pwd`'",
                           fail_on_error: true)

      expect(last_command_output).to include("hi #{umbrella.path.join('auth')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('directory')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('finance')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('hr')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('sales')}")
    end

    it "executes the given command a given component" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} hr 'echo \"hi\" `pwd`'",
                           fail_on_error: true)

      expect(last_command_output).to include("hi #{umbrella.path.join('hr')}")
    end

    it "executes the given command a given component's dependents" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --dependents directory 'echo \"hi\" `pwd`'",
                           fail_on_error: true)

      expect(last_command_output).to include("hi #{umbrella.path.join('directory')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('finance')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('hr')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('sales')}")
    end

    it "executes the given selecting by plugin" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --memory " \
                           "--dependents directory 'echo \"hi\" `pwd`'",
                           fail_on_error: true)

      expect(last_command_output).to include("hi #{umbrella.path.join('directory')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('payroll')}")
    end

    it "executes the given command a given component's dependencies" do
      run_command_and_stop("cobra exec --no-interactive -a #{umbrella.path} --dependencies finance 'echo \"hi\" `pwd`'",
                           fail_on_error: true)

      expect(last_command_output).to include("hi #{umbrella.path.join('auth')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('directory')}")
      expect(last_command_output).to include("hi #{umbrella.path.join('finance')}")
    end
  end

  describe "cobra cmd --no-interactive" do
    let(:umbrella) { stub_umbrella("app") }

    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra cmd --no-interactive -a #{umbrella.path} non_existent pwd", fail_on_error: false)

      expect(last_command_started).to_not be_successfully_executed
      expect(last_command_output).to match(/Component non_existent not found/)
    end

    it "executes the given command from all available sources" do
      run_command_and_stop("cobra cmd --no-interactive -a #{umbrella.path} --no-self deps",
                           fail_on_error: true)

      expect(last_command_output).to include("install memory deps")
      expect(last_command_output).to include("install stub deps")
    end

    it "executes the given selecting by plugin" do
      run_command_and_stop("cobra cmd --no-interactive -a #{umbrella.path} --memory " \
                           "--dependents directory deps",
                           fail_on_error: true)

      expect(last_command_output).to include("install memory deps")
    end

    it "exists with error when a job fails" do
      run_command_and_stop("cobra cmd --no-interactive -a #{umbrella.path} --memory " \
                           "--dependents directory failing_command",
                           fail_on_error: false)

      expect(last_command_started).to_not be_successfully_executed
    end
  end

  describe "cobra graph" do
    let(:umbrella) { stub_umbrella("app") }

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
        run_command_and_stop("cobra graph -a #{umbrella.path} sales", fail_on_error: true)
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
    let(:umbrella) { stub_umbrella("app") }

    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra tree -a #{umbrella.path} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found/)
    end

    it "outputs the tree of components from umbrella when no component is specified" do
      run_command_and_stop("cobra tree -a #{umbrella.path}", fail_on_error: true)

      expected_output = <<~OUTPUT
        auth
        directory
        └── auth
        finance
        ├── auth
        ├── directory
        │   └── auth
        └── payroll
            └── directory
                └── auth
        finance_models
        └── finance
            ├── auth
            ├── directory
            │   └── auth
            └── payroll
                └── directory
                    └── auth
        hr
        ├── auth
        └── directory
            └── auth
        payroll
        └── directory
            └── auth
        sales
        ├── auth
        ├── directory
        │   └── auth
        └── finance
            ├── auth
            ├── directory
            │   └── auth
            └── payroll
                └── directory
                    └── auth
      OUTPUT

      # This converts a unicode non-breaking space with
      # a normal space because editors.
      expected_output = expected_output.strip.tr("\u00a0", " ")

      expect(last_command_output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end

    it "outputs the tree of components from umbrella with specific plugins enabled" do
      run_command_and_stop("cobra tree -a #{umbrella.path} --memory", fail_on_error: true)

      expected_output = <<~OUTPUT
        directory
        finance
        └── payroll
            └── directory
        finance_models
        └── finance
            └── payroll
                └── directory
        payroll
        └── directory
      OUTPUT

      # This converts a unicode non-breaking space with
      # a normal space because editors.
      expected_output = expected_output.strip.tr("\u00a0", " ")

      expect(last_command_output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end

    it "outputs the tree of components from the specified component" do
      run_command_and_stop("cobra tree -a #{umbrella.path} sales", fail_on_error: true)

      expected_output = <<~OUTPUT
        sales
        ├── auth
        ├── directory
        │   └── auth
        └── finance
            ├── auth
            ├── directory
            │   └── auth
            └── payroll
                └── directory
                    └── auth
      OUTPUT

      # This converts a unicode non-breaking space with
      # a normal space because editors.
      expected_output = expected_output.strip.tr("\u00a0", " ")

      expect(last_command_output.strip.tr("\u00a0", " ")).to eq(expected_output)
    end
  end

  describe "cobra changes" do
    let(:umbrella) { stub_umbrella("modified-app", unpack: true) }

    it "does not output 'Test scripts to run' header" do
      run_command_and_stop("cobra changes -a #{umbrella.path} -b main", fail_on_error: false)

      expect(last_command_output).to_not include("Test scripts to run")
      expect(last_command_output).to include("modified-app/finance/test.sh")
      expect(last_command_output).to include("modified-app/sales/test.sh")
    end

    context "with full results" do
      it "outputs all headers" do
        run_command_and_stop("cobra changes -a #{umbrella.path} -r full -b main", fail_on_error: true)

        expect(last_command_output).to include("Changes since last commit on main")
        expect(last_command_output).to include("Directly affected components")
        expect(last_command_output).to include("Transitively affected components")
        expect(last_command_output).to include("Test scripts to run")
      end
    end

    context "with incorrect results specified" do
      it "outputs error message" do
        run_command_and_stop("cobra changes -a #{umbrella.path} -b main -r partial", fail_on_error: false)

        expect(last_command_output).to match "--results must be 'test', 'full', 'name' or 'json'"
      end
    end

    context "with nonexistent branch specified" do
      it "outputs specified branch in 'Changes since' header" do
        run_command_and_stop("cobra changes -a #{umbrella.path} -r full -b oak_branch", fail_on_error: true)

        expect(last_command_output).to include("Changes since last commit on oak_branch")
        expect(last_command_output).to include("Specified branch oak_branch could not be found")
        expect(last_command_output).to_not include("Test scripts to run")
      end
    end
  end

  describe "cobra ls" do
    let(:umbrella) { stub_umbrella("app") }

    it "lists components affected by changes in a branch" do
      umbrella = stub_umbrella("modified-app", unpack: true)

      run_command_and_stop("cobra ls -a #{umbrella.path} --affected main", fail_on_error: true)

      expect(last_command_output).to eq("finance\nfinance_models\nsales")
    end

    it "errors gently if component doesn't exist" do
      run_command_and_stop("cobra ls -a #{umbrella.path} non_existent", fail_on_error: false)

      expect(last_command_output).to match(/Component non_existent not found, maybe one of "cobra ls"/)
    end

    it "suggests when there's any DidYouMean match", if: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{umbrella.path} sals", fail_on_error: false)

      expect(last_command_output).to match(/Component sals not found, maybe sales, one of "cobra ls"/)
    end

    it "suggests with DidYouMean when one of the list does not exist", if: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{umbrella.path} sals,hr,auth", fail_on_error: false)

      expect(last_command_output).to match(/Component sals not found, maybe sales, one of "cobra ls"/)
    end

    it "has a default suggestion when there isn't DidYouMean", unless: RUBY_2_7 do
      run_command_and_stop("cobra ls -a #{umbrella.path} node_manifeast", fail_on_error: false)

      expect(last_command_output).to match(/Component node_manifeast not found, maybe one of "cobra ls"/)
    end

    it "lists a comma separated list of components" do
      run_command_and_stop("cobra ls -a #{umbrella.path} hr,sales,finance", fail_on_error: false)

      expect(last_command_output.strip.split("\n")).to match(%w[finance hr sales])
    end

    it "lists components uniquely" do
      run_command_and_stop("cobra ls -a #{umbrella.path} sales,sales,finance", fail_on_error: false)

      expect(last_command_output.strip.split("\n")).to match(%w[finance sales])
    end

    describe "cobra ls component --dependents" do
      it "lists a component's direct dependents" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents --no-self finance", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[finance_models sales])
      end

      it "lists a component itself along with dependents by default" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents finance", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[finance finance_models sales])
      end

      it "lists a component itself along with dependents by default" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents directory", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match(%w[directory finance finance_models hr payroll sales])
      end

      it "counts a component's transient dependents" do
        run_command_and_stop("cobra ls -a #{umbrella.path} --dependents -t --no-self auth", fail_on_error: true)

        expect(last_command_output.to_i).to eq(6)
      end
    end

    describe "cobra ls component --dependencies" do
      it "can list only a specified plugin dependencies" do
        run_command_and_stop("cobra ls --memory --dependencies --no-self -a #{umbrella.path} payroll",
                             fail_on_error: true)

        expect(last_command_output).to eql "directory"
      end

      it "lists a component's dependencies without self" do
        run_command_and_stop("cobra ls --no-self --dependencies -a #{umbrella.path} finance", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[auth directory payroll]
      end

      it "lists a component itself along with dependents by default" do
        run_command_and_stop("cobra ls --dependencies -a #{umbrella.path} finance", fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[auth directory finance payroll]
      end

      it "lists a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self --memory -a #{umbrella.path} finance",
                             fail_on_error: true)

        expect(last_command_output.strip.split("\n")).to match_array %w[directory payroll]
      end

      it "counts a component's transient dependency" do
        run_command_and_stop("cobra ls --dependencies --no-self --memory -a #{umbrella.path} -t finance",
                             fail_on_error: true)

        expect(last_command_output.strip.to_i).to eq(2)
      end
    end
  end
end
