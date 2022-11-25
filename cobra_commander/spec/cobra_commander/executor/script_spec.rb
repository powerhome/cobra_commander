# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Script do
  let(:finance_component) { stub_umbrella("app", memory: true, stub: true).find("finance") }
  let(:finance_package) { finance_component.packages.first }

  def run_script(package, script)
    CobraCommander::Executor::Script.new(package, script).call
  end

  describe ".for(components, script)" do
    it "generates one script for each unique package path" do
      scripts = CobraCommander::Executor::Script.for([finance_component], "pwd")

      expect(scripts.size).to eql 1
      expect(finance_component.packages.size).to eql 2
    end
  end

  it "executes in the context of the given component" do
    result, output = run_script(finance_package, "echo 'I am at' $PWD")

    expect(result).to be :success
    expect(output).to include("I am at #{finance_package.path}")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    result, output = run_script(finance_package, "bundle exec env")

    expect(result).to be :success
    expect(output).to_not include("Install missing gem executables with")
  end

  it "executes the command in the given bundle context" do
    Bundler::ORIGINAL_ENV["BUNDLE_GEMFILE"] = "Funny"

    result, output = run_script(finance_package, "env")

    expect(result).to be :success
    expect(output).to_not match(/BUNDLE_GEMFILE/)
  end

  it "fails when the script fails" do
    result, output = run_script(finance_package, "lol_I_clearly_dont_exist_as_a_command_please")

    expect(result).to be :error
    expect(output).to match(/lol_I_clearly_dont_exist_as_a_command_please.*not found/)
  end
end
