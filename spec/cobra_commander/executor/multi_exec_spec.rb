# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor/multi_exec"

RSpec.describe CobraCommander::Executor::MultiExec do
  let(:spin_output) { StringIO.new }
  let(:cmmd_output) { StringIO.new }
  let(:component_e) { fixture_umbrella.find("e") }
  subject { CobraCommander::Executor::MultiExec.new(component_e.dependents) }
  before do
    allow(spin_output).to receive(:tty?) { true }
  end

  it "executes in the context of each given component" do
    subject.run("echo 'I am at' $PWD", output: cmmd_output, spin_output: spin_output, only_output_on_error: false)

    expect(cmmd_output.string).to match(/I am at .*components\/b$/)
    expect(cmmd_output.string).to match(/I am at .*node_manifest$/)
    expect(cmmd_output.string).to match(/I am at .*components\/g$/)
  end

  it "prints the status of each component" do
    subject.run("echo 'I am at' $PWD", output: cmmd_output, spin_output: spin_output)

    expect(spin_output.string).to match(/\[DONE\]\e\[0m b/)
    expect(spin_output.string).to match(/\[DONE\]\e\[0m node_manifest/)
    expect(spin_output.string).to match(/\[DONE\]\e\[0m g/)
  end
end
