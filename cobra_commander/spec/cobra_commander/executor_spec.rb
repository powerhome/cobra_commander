# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  describe ".execute_and_handle_exit(jobs:, runner:, workers:, printer: :quiet, &name_f)" do
    it "prints all output as it goes when only one job is given" do
      runner = ->(tty, *args) do
        expect(tty.printer).to be_a TTY::Command::Printers::Quiet
        args
      end
      CobraCommander::Executor.execute_and_handle_exit(
        jobs: [[:success, "go brazil"]],
        interactive: false,
        workers: 1,
        runner: runner,
        &:last
      )
    end

    it "prints the output buffered when multiple jobs are executed in non-interactive mode" do
      runner = ->(tty, *args) do
        expect(tty.printer).to be_a CobraCommander::Executor::BufferedPrinter
        args
      end
      CobraCommander::Executor.execute_and_handle_exit(
        jobs: [[:success, "go brazil"], [:success, "go go"]],
        interactive: false,
        workers: 1,
        runner: runner,
        &:last
      )
    end

    it "exits with error when a job fails in non-interactive mode" do
      expect do
        CobraCommander::Executor.execute_and_handle_exit(
          jobs: [[:success, "go brazil"], [:error, "go go"]],
          interactive: false,
          workers: 1,
          runner: ->(_, *args) { args },
          &:last
        )
      end.to raise_error SystemExit
    end
  end
end
