# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor/component_exec"

RSpec.describe CobraCommander::Executor::ComponentExec do
  let(:output) { StringIO.new }
  let(:component_e) { fixture_umbrella.find("e") }
  subject { CobraCommander::Executor::ComponentExec.new(component_e) }

  it "executes in the context of the given component" do
    subject.run("echo 'I am at' $PWD", output: output)

    expect(output.string).to include("I am at #{component_e.root_paths.first}")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    subject.run("bundle exec env", output: output)

    expect(output.string).to_not include("Install missing gem executables with")
  end

  it "allows to override cmd options" do
    subject.run("pwd", only_output_on_error: true, output: output)

    expect(output.string).to be_empty
  end
end
