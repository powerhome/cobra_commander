# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::IsolatedPTY do
  it "executes the command in the given bundle context" do
    Bundler::ORIGINAL_ENV["BUNDLE_GEMFILE"] = "Funny"

    output = StringIO.new

    pty = CobraCommander::Executor::IsolatedPTY.new(printer: :quiet, output: output)
    result = pty.run!("env", err: :out)

    expect(result).to be_success
    expect(output.string).to_not match(/BUNDLE_GEMFILE/)
  end
end
