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

  it "fails when the script fails" do
    result, output = run_script(finance_component, "lol_I_clearly_dont_exist_as_a_command_please")

    expect(result).to be :error
    expect(output).to match(/lol_I_clearly_dont_exist_as_a_command_please.*not found/)
  end

  it "passes the env yielded by the component's around_command to the script" do
    component = component_with(env: { "COBRA_TEST" => "from-component" })

    result, output = run_script(component, "echo $COBRA_TEST")

    expect(result).to be :success
    expect(output).to include("from-component")
  end

  it "wraps execution in the component's around_command" do
    source = source_yielding({})
    component = component_with(source: source)

    run_script(component, "echo hi")

    expect(source).to have_received(:around_command)
  end

  def source_yielding(env)
    double("source", key: :ruby).tap do |s|
      allow(s).to receive(:around_command) { |&block| block.call(env) }
    end
  end

  def component_with(env: {}, source: nil)
    source ||= source_yielding(env)
    CobraCommander::Component.new(double("umbrella"), "finance").tap do |c|
      c.add_package(CobraCommander::Package.new(source, name: "finance", path: Dir.pwd, dependencies: []))
    end
  end
end
