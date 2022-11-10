# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  let(:spin_output) { StringIO.new }
  let(:component_path) { Pathname.new(__dir__) }
  let(:package) { CobraCommander::Package.new(nil, path: component_path, dependencies: [], name: nil) }
  let(:component) { CobraCommander::Component.new(nil, "component_a") }
  let(:another_component_path) { fixture_path }
  let(:another_package) { CobraCommander::Package.new(nil, path: another_component_path, dependencies: [], name: nil) }
  let(:another_component) { CobraCommander::Component.new(nil, "component_b") }
  before do
    component.add_package(package)
    another_component.add_package(another_package)

    # TTY::Spinner::Multi will not print if it's not a TTY IO
    allow(spin_output).to receive(:tty?) { true }
  end
  subject do
    ::CobraCommander::Executor.new([component, another_component], concurrency: 1, spin_output: spin_output)
  end

  it "executes in the context of each given component" do
    contexts = subject.exec("echo 'I am at' $PWD")
    outputs = contexts.map(&:output).join

    expect(contexts.size).to eql 2
    expect(outputs).to match(/I am at #{component_path}$/)
    expect(outputs).to match(/I am at #{another_component_path}$/)
  end

  it "prints the status of each component" do
    subject.exec("echo 'I am at' $PWD")

    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? component_a/)
    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? component_b/)
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
