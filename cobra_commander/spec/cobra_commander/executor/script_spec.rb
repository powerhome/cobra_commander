# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Script do
  let(:finance_component) { stub_umbrella("app", memory: true, stub: true).find("finance") }
  let(:finance_package) { finance_component.packages.first }
  let(:pty) { TTY::Command.new(printer: :null) }

  def run_script(component, script)
    CobraCommander::Executor::Script.new(script).call(pty, component)
  end

  it "executes in the context of the given component" do
    result, output = run_script(finance_component, "echo 'I am at' $PWD")

    expect(result).to be :success
    expect(output).to include("I am at #{finance_package.path}")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    result, output = run_script(finance_component, "bundle exec env")

    expect(result).to be :success
    expect(output).to_not include("Install missing gem executables with")
  end

  it "fails when the script fails" do
    result, output = run_script(finance_component, "lol_I_clearly_dont_exist_as_a_command_please")

    expect(result).to be :error
    expect(output).to match(/lol_I_clearly_dont_exist_as_a_command_please.*not found/)
  end
end
