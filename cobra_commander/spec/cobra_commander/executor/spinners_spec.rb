# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Spinners do
  let(:spin_output) { StringIO.new }
  # TTY::Spinner::Multi will not print if it's not a TTY IO
  before { allow(spin_output).to receive(:tty?).and_return(true) }

  it "displays the running state of each job" do
    execution = {
      "job 1" => ::Concurrent::Promises.resolvable_future,
      "job 2" => ::Concurrent::Promises.resolvable_future,
    }

    CobraCommander::Executor::Spinners.start(execution, output: spin_output)

    expect(spin_output.string).to match(/\[[= ]+\](\e\[0m)? job 1/)
    expect(spin_output.string).to match(/\[[= ]+\](\e\[0m)? job 2/)
  end

  it "shows a succesful and a failed completed job" do
    executor = Concurrent::ImmediateExecutor.new
    execution = {
      "job 1" => ::Concurrent::Promises.resolvable_future_on(executor),
      "job 2" => ::Concurrent::Promises.resolvable_future_on(executor),
    }

    CobraCommander::Executor::Spinners.start(execution, output: spin_output)

    expect(spin_output.string).to match(/\[[= ]+\](\e\[0m)? job 1/)
    expect(spin_output.string).to match(/\[[= ]+\](\e\[0m)? job 2/)

    execution["job 1"].resolve("lol")
    execution["job 2"].reject("lol")

    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? job 1/)
    expect(spin_output.string).to match(/\[ERROR\](\e\[0m)? job 2/)
  end
end
