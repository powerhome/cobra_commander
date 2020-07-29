# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  it "executes the given command once on each element of the tree" do
    output = StringIO.new
    CobraCommander::Executor.exec(fixture_umbrella.components, "pwd", output)

    expect(output.string).to include("===> a (#{fixture_app}/components/a)")
    expect(output.string).to include("===> b (#{fixture_app}/components/b)")
    expect(output.string).to include("===> c (#{fixture_app}/components/c)")
    expect(output.string).to include("===> d (#{fixture_app}/components/d)")
    expect(output.string).to include("===> e (#{fixture_app}/components/e)")
    expect(output.string).to include("===> f (#{fixture_app}/components/f)")
    expect(output.string).to include("===> g (#{fixture_app}/components/g)")
    expect(output.string).to include("===> h (#{fixture_app}/components/h)")
    expect(output.string).to include("===> node_manifest (#{fixture_app}/node_manifest)")
  end

  it "cleans BUNDLE environment so a nested bundle call can succeed" do
    output = StringIO.new

    CobraCommander::Executor.exec([fixture_umbrella.find("e")], "bundle exec env", output)

    expect(output.string).to_not include("Install missing gem executables with")
  end
end
