# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  let(:output) { StringIO.new }

  describe ".exec" do
    it "executes the given command with full output when its a single component" do
      contexts = CobraCommander::Executor.exec(components: [fixture_umbrella.find("a")],
                                               command: "pwd", concurrency: 1, status_output: output)

      expect(contexts.map(&:output)).to match_array ["#{fixture_app}/components/a\n\n"]
    end

    it "executes the given command with status output only when multiple components are given" do
      CobraCommander::Executor.exec(components: fixture_umbrella.components, command: "pwd",
                                    concurrency: 1, status_output: output)

      expect(output.string).to_not include("[DONE]")
    end
  end
end
