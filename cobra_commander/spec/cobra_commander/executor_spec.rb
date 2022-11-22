# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  let(:umbrella) { stub_umbrella("app") }
  let(:spin_output) { StringIO.new }
  # TTY::Spinner::Multi will not print if it's not a TTY IO
  before { allow(spin_output).to receive(:tty?).and_return(true) }

  include ::CobraCommander::Executor::Job

  def success_job(output)
    -> { success(output) }
  end

  def error_job(output)
    -> { error(output) }
  end

  describe ".execute(jobs:, status_output: nil, **kwargs)" do
    subject do
      CobraCommander::Executor.execute(
        jobs: [success_job("go brazil"), error_job("didn't happen")],
        workers: 1,
        status_output: spin_output
      )
    end

    it "handles the status of each job" do
      outputs = subject.wait

      expect(outputs.value).to match_array ["go brazil", nil]
      expect(outputs.reason).to match_array [nil, "didn't happen"]
      expect(spin_output.string).to match(/\[DONE\](\e\[0m)? .*Proc/)
      expect(spin_output.string).to match(/\[ERROR\](\e\[0m)? .*Proc/)
    end
  end

  describe ".execute_script(components:, script:, **kwargs)" do
    context "when it succeeds" do
      subject do
        ::CobraCommander::Executor.execute_script(
          components: umbrella.components,
          script: "echo 'I am at' $PWD",
          workers: 1,
          status_output: spin_output
        )
      end

      it "executes in the context of each given component" do
        outputs = subject.wait.value

        expect(outputs.size).to eql 5
        expect(outputs).to match_array([
                                         /I am at #{umbrella.path.join("auth")}$/,
                                         /I am at #{umbrella.path.join("directory")}$/,
                                         /I am at #{umbrella.path.join("finance")}$/,
                                         /I am at #{umbrella.path.join("hr")}$/,
                                         /I am at #{umbrella.path.join("sales")}$/,
                                       ])
      end

      it "prints the status of each component" do
        subject.wait

        expect(spin_output.string).to match(/\[DONE\](\e\[0m)? auth/)
        expect(spin_output.string).to match(/\[DONE\](\e\[0m)? directory/)
        expect(spin_output.string).to match(/\[DONE\](\e\[0m)? finance/)
        expect(spin_output.string).to match(/\[DONE\](\e\[0m)? hr/)
        expect(spin_output.string).to match(/\[DONE\](\e\[0m)? sales/)
      end

      it "succeeds when it succeed" do
        result = subject.wait

        expect(result).to be_fulfilled
      end
    end

    context "when a job fails" do
      subject do
        ::CobraCommander::Executor.execute_script(
          components: umbrella.components,
          script: "lol",
          status_output: spin_output,
          workers: 1
        )
      end

      it "fails when the command fail" do
        reason = subject.wait.reason

        expect(reason).to match_array([/lol: command not found\n/] * 5)
      end

      it "prints the status of each failed component" do
        subject.wait

        expect(spin_output.string).to match(/\[ERROR\](\e\[0m)? auth/)
        expect(spin_output.string).to match(/\[ERROR\](\e\[0m)? directory/)
        expect(spin_output.string).to match(/\[ERROR\](\e\[0m)? finance/)
        expect(spin_output.string).to match(/\[ERROR\](\e\[0m)? hr/)
        expect(spin_output.string).to match(/\[ERROR\](\e\[0m)? sales/)
      end
    end
  end
end
