# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Context do
  let(:hr_component) { stub_umbrella("app").find("hr") }

  it "executes in the context of the given component" do
    context = CobraCommander::Executor::Context.new(hr_component, "echo 'I am at' $PWD")

    expect(context.output).to include("I am at #{hr_component.root_paths.first}")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    context = CobraCommander::Executor::Context.new(hr_component, "bundle exec env")

    expect(context.output).to_not include("Install missing gem executables with")
  end

  it "executes the command in the given bundle context" do
    Bundler::ORIGINAL_ENV["BUNDLE_GEMFILE"] = "Funny"

    context = CobraCommander::Executor::Context.new(hr_component, "env")

    expect(context.output).to_not match(/BUNDLE_GEMFILE/)
  end
end
