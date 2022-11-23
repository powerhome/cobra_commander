# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Script do
  let(:hr_component) { stub_umbrella("app").find("hr") }

  def run_script(component, script)
    CobraCommander::Executor::Script.new(component.name, component.root_paths.first, script)
                                    .call
  end

  it "executes in the context of the given component" do
    result, output = run_script(hr_component, "echo 'I am at' $PWD")

    expect(result).to be :success
    expect(output).to include("I am at #{hr_component.root_paths.first}")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    result, output = run_script(hr_component, "bundle exec env")

    expect(result).to be :success
    expect(output).to_not include("Install missing gem executables with")
  end

  it "executes the command in the given bundle context" do
    Bundler::ORIGINAL_ENV["BUNDLE_GEMFILE"] = "Funny"

    result, output = run_script(hr_component, "env")

    expect(result).to be :success
    expect(output).to_not match(/BUNDLE_GEMFILE/)
  end

  it "fails when the script fails" do
    result, output = run_script(hr_component, "lol_I_clearly_dont_exist_as_a_command_please")

    expect(result).to be :error
    expect(output).to match(/lol_I_clearly_dont_exist_as_a_command_please.*not found/)
  end
end
