# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor/component_exec"

RSpec.describe CobraCommander::Executor::ComponentExec do
  let(:output) { StringIO.new }
  let(:component_d) { fixture_umbrella.find("d") }
  subject { CobraCommander::Executor::ComponentExec.new(component_d) }

  it "executes in the context of the given component" do
    subject.run("echo 'I am at' $PWD", output: output)

    expect(output.string).to include("I am at #{component_d.root_paths.first}")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    subject.run("bundle exec env", output: output)

    expect(output.string).to_not include("Install missing gem executables with")
  end

  it "executes the command in the given bundle context" do
    Bundler::ORIGINAL_ENV["BUNDLE_GEMFILE"] = File.expand_path(
      "../../../../Gemfile",
      Pathname.new(__FILE__).realpath
    )

    subject.run("bundle list", output: output)

    expect(output.string).to eql <<~OUT
      Gems included by the bundle:
        * b (0.0.1)
        * bundler (1.17.3)
        * c (0.0.1)
        * d (0.0.1)
        * rake (12.0.0)
    OUT
  end

  it "allows to override cmd options" do
    subject.run("pwd", only_output_on_error: true, output: output)

    expect(output.string).to be_empty
  end
end
