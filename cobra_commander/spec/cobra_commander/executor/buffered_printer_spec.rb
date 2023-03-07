# frozen_string_literal: true

require "spec_helper"
require "securerandom"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::BufferedPrinter do
  let(:output) { StringIO.new }
  # TTY::Spinner::Multi will not print if it's not a TTY IO
  # before { allow(spin_output).to receive(:tty?).and_return(true) }

  def new_cmd(cmd, uuid = SecureRandom.uuid)
    double(to_command: cmd, uuid: uuid)
  end

  subject { CobraCommander::Executor::BufferedPrinter.new(output) }

  it "only prints after the command is completed" do
    cmd = new_cmd("say hi")

    subject.print_command_start(cmd)
    subject.print_command_out_data(cmd, "LOL 1\n")
    subject.print_command_out_data(cmd, "LOL 2\n")
    subject.print_command_out_data(cmd, "LOL 3\n")

    expect(output.string).to be_empty

    subject.print_command_exit(cmd, 0, 10)

    expect(output.string).to eql <<~OUTPUT
      Running \e[33;1msay hi\e[0m LOL 1
      LOL 2
      LOL 3
      \e[32mFinished in 10.000s with exit status 0\e[0m

    OUTPUT
  end

  it "only prints exit in red when it fails" do
    cmd = new_cmd("say hi")

    subject.print_command_start(cmd)
    subject.print_command_out_data(cmd, "LOL\n")

    expect(output.string).to be_empty

    subject.print_command_exit(cmd, 1, 10)

    expect(output.string).to eql <<~OUTPUT
      Running \e[33;1msay hi\e[0m LOL
      \e[31mFinished in 10.000s with exit status 1\e[0m

    OUTPUT
  end
end
