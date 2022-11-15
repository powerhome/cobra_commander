# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  let(:spin_output) { StringIO.new }
  let(:umbrella) { stub_umbrella("app") }
  # TTY::Spinner::Multi will not print if it's not a TTY IO
  before { allow(spin_output).to receive(:tty?).and_return(true) }
  subject do
    ::CobraCommander::Executor.new(umbrella.components, concurrency: 1, spin_output: spin_output)
  end

  it "executes in the context of each given component" do
    contexts = subject.exec("echo 'I am at' $PWD")
    outputs = contexts.map(&:output).join

    expect(contexts.size).to eql 5
    expect(outputs).to match(/I am at #{umbrella.path.join("auth")}$/)
    expect(outputs).to match(/I am at #{umbrella.path.join("directory")}$/)
    expect(outputs).to match(/I am at #{umbrella.path.join("finance")}$/)
    expect(outputs).to match(/I am at #{umbrella.path.join("hr")}$/)
    expect(outputs).to match(/I am at #{umbrella.path.join("sales")}$/)
  end

  it "prints the status of each component" do
    subject.exec("echo 'I am at' $PWD")

    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? auth/)
    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? directory/)
    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? finance/)
    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? hr/)
    expect(spin_output.string).to match(/\[DONE\](\e\[0m)? sales/)
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
