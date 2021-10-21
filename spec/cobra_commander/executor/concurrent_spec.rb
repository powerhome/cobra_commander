# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Concurrent do
  let(:spin_output) { StringIO.new }
  let(:component_e) { fixture_umbrella.find("e") }
  subject { CobraCommander::Executor::Concurrent.new(component_e.dependents, concurrency: 1, spin_output: spin_output) }
  before do
    allow(spin_output).to receive(:tty?) { true }
  end

  it "executes in the context of each given component" do
    contexts = subject.exec("echo 'I am at' $PWD")
    outputs = contexts.map(&:output).join

    expect(outputs).to match(%r{I am at .*components/b$})
    expect(outputs).to match(/I am at .*node_manifest$/)
    expect(outputs).to match(%r{I am at .*components/g$})
  end

  it "prints the status of each component" do
    subject.exec("echo 'I am at' $PWD")

    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? b/)
    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? node_manifest/)
    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? g/)
  end

  it "fails when the command fail" do
    contexts = subject.exec("lol")

    expect(contexts.all?(&:success?)).to be false
  end

  it "succeeds when it succeed" do
    contexts = subject.exec("true")

    expect(contexts.all?(&:success?)).to be true
  end
end
