# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::RunScript do
  let(:runner) do
    Class.new do
      include CobraCommander::Executor::RunScript
    end.new
  end
  let(:tty) { TTY::Command.new(printer: :null) }

  describe "#run_script" do
    it "passes the given env to the executed shell" do
      result, output = runner.run_script(tty, "echo $COBRA_TEST", Dir.pwd, env: { "COBRA_TEST" => "hello" })

      expect(result).to be :success
      expect(output).to include("hello")
    end

    it "runs with an empty env by default" do
      result, output = runner.run_script(tty, "echo ok", Dir.pwd)

      expect(result).to be :success
      expect(output).to include("ok")
    end
  end
end
