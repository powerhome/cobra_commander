# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::IsolatedPTY do
  it "is a TTY::Command" do
    expect(described_class.new(printer: :null)).to be_a(TTY::Command)
  end

  it "scopes a supplied env to the execution without leaking it into the parent" do
    output = StringIO.new

    pty = described_class.new(printer: :quiet, output: output)
    result = pty.run!({ "COBRA_TEST" => "scoped" }, "env", err: :out)

    expect(result).to be_success
    expect(output.string).to match(/COBRA_TEST=scoped/)
    expect(ENV).to_not have_key("COBRA_TEST")
  end
end
