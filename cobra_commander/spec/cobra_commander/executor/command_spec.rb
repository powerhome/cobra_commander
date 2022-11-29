# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Command do
  let(:finance_component) { stub_umbrella("app", memory: true, stub: true).find("finance") }
  let(:finance_stub_package) { finance_component.packages.find { |p| p.key == :stub } }

  def run_command(package, command)
    CobraCommander::Executor::Command.new(package, command).call
  end

  describe ".for(components, script)" do
    it "generates one command job for each package" do
      scripts = CobraCommander::Executor::Command.for([finance_component], "deps")

      expect(scripts.size).to eql 2
      expect(finance_component.packages.size).to eql 2
    end
  end

  it "executes the command configured in cobra.yml" do
    result, output = run_command(finance_stub_package, "deps")

    expect(result).to be :success
    expect(output).to eql "install stub deps\n"
  end

  it "skips when the command does not exist" do
    result, output = run_command(finance_stub_package, "lol_I_clearly_dont_exist_as_a_command_please")

    expect(result).to be :skip
    expect(output).to eql "Command lol_I_clearly_dont_exist_as_a_command_please does not exist. " \
                          "Check your cobra.yml for existing commands in stub."
  end

  describe "command criteria" do
    describe "depends_on" do
      let(:command) do
        {
          "if" => { "depends_on" => %w[auth] },
          "run" => "echo 'lol'",
        }
      end
      let(:source) { double("le source", config: { "commands" => { "my_command" => command } }) }
      let(:package_dependent) do
        CobraCommander::Package.new(source, path: "./", dependencies: %w[directory auth], name: "management")
      end
      let(:package_not_dependent) do
        CobraCommander::Package.new(source, path: "./", dependencies: %w[directory], name: "management")
      end

      it "executes on packages matching the criteria" do
        result, output = run_command(package_dependent, "my_command")

        expect(result).to be :success
        expect(output).to eql "lol\n"
      end

      it "skips packages not matching the criteria" do
        result, output = run_command(package_not_dependent, "my_command")

        expect(result).to be :skip
        expect(output).to eql "Package management does not match criteria."
      end
    end
  end
end
