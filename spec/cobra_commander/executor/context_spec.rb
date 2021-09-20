# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Context do
  let(:output) { StringIO.new }
  let(:component_d) { fixture_umbrella.find("d") }

  it "executes in the context of the given component" do
    context = CobraCommander::Executor::Context.new(component_d, "echo 'I am at' $PWD")

    expect(context.output).to include("I am at #{component_d.root_paths.first}")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    context = CobraCommander::Executor::Context.new(component_d, "bundle exec env")

    expect(context.output).to_not include("Install missing gem executables with")
  end

  it "executes the command in the given bundle context" do
    Bundler::ORIGINAL_ENV["BUNDLE_GEMFILE"] = File.expand_path(
      "../../../../Gemfile",
      Pathname.new(__FILE__).realpath
    )

    context = CobraCommander::Executor::Context.new(component_d, "bundle lock")

    expect(context.output).to match %r{^Writing lockfile to .*/components/d/Gemfile.lock$}
  end
end
