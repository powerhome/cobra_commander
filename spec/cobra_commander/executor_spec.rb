# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  describe ".exec" do
    it "executes the given command with full output when its a single component" do
      output = StringIO.new
      CobraCommander::Executor.exec(fixture_umbrella.find("a"), "pwd", output)

      expect(output.string).to eq "#{fixture_app}/components/a\n"
    end

    it "executes the given command with status output only when multiple components are given" do
      output = StringIO.new
      CobraCommander::Executor.exec(fixture_umbrella.components, "pwd", output, output)

      expect(output.string).to_not include("[DONE]")
    end
  end
end
