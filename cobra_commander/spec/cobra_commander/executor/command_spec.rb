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

  describe "sequential execution" do
    let(:will_skip) do
      {
        "if" => { "depends_on" => ["i_dont_exist"] },
        "run" => "doesn't matter wont run",
      }
    end
    let(:failing_command) { "i just fail" }
    let(:command_rofl) { "echo 'rofl'" }
    let(:command_lol) { "echo 'lol'" }
    let(:source) do
      double("le source", key: "le",
                          config: {
                            "commands" => {
                              "skp" => will_skip,
                              "fail" => failing_command,
                              "rofl" => command_rofl,
                              "lol" => command_lol,
                              "lol_and_fail" => %w[lol fail rofl],
                              "ltc" => %w[lol rofl],
                              "ltc_lol" => %w[ltc lol],
                              "lol_skip_rolf" => %w[lol skp rofl],
                              "lol_skip" => %w[lol skp],
                            },
                          })
    end
    let(:package) { CobraCommander::Package.new(source, path: "./", dependencies: [], name: "management") }

    it "can run other commands in a sequential order" do
      result, output = run_command(package, "ltc")

      expect(result).to be :success
      expect(output).to eql "lol\nrofl"
    end

    it "stops when one command fails" do
      result, output = run_command(package, "lol_and_fail")

      expect(result).to be :error
      expect(output).to eql "lol\nsh: i: command not found"
    end

    it "allows nested dependency" do
      result, output = run_command(package, "ltc_lol")

      expect(result).to be :success
      expect(output).to eql "lol\nrofl\nlol"
    end

    it "skips conditional commands" do
      result, output = run_command(package, "lol_skip_rolf")

      expect(result).to be :success
      expect(output).to eql "lol\nPackage management does not match criteria.\nrofl"
    end

    it "succeeds when last command skips" do
      result, output = run_command(package, "lol_skip")

      expect(result).to be :success
      expect(output).to eql "lol\nPackage management does not match criteria."
    end
  end
end
