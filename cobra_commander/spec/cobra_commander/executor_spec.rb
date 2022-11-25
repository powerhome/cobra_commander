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
end
