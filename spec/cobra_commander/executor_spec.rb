# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor do
  let(:umbrella) { CobraCommander.umbrella(AppHelper.root) }

  it "executes the given command once on each element of the tree" do
    output = StringIO.new
    CobraCommander::Executor.exec(umbrella.components, "pwd", output)

    expect(output.string).to match %r{===> a \(.*spec/fixtures/app/components/a\)}
    expect(output.string).to match %r{===> b \(.*spec/fixtures/app/components/b\)}
    expect(output.string).to match %r{===> c \(.*spec/fixtures/app/components/c\)}
    expect(output.string).to match %r{===> d \(.*spec/fixtures/app/components/d\)}
    expect(output.string).to match %r{===> e \(.*spec/fixtures/app/components/e\)}
    expect(output.string).to match %r{===> f \(.*spec/fixtures/app/components/f\)}
    expect(output.string).to match %r{===> g \(.*spec/fixtures/app/components/g\)}
    expect(output.string).to match %r{===> h \(.*spec/fixtures/app/components/h\)}
    expect(output.string).to match %r{===> node_manifest \(.*spec/fixtures/app/node_manifest\)}
  end

  it "executes with clean environment" do
    output = StringIO.new
    CobraCommander::Executor.exec(umbrella.components, "env", output)

    expect(output.string).to match %r{===> a \(.*spec/fixtures/app/components/a\)\n^$}
    expect(output.string).to match %r{===> b \(.*spec/fixtures/app/components/b\)\n^$}
    expect(output.string).to match %r{===> c \(.*spec/fixtures/app/components/c\)\n^$}
    expect(output.string).to match %r{===> d \(.*spec/fixtures/app/components/d\)\n^$}
    expect(output.string).to match %r{===> e \(.*spec/fixtures/app/components/e\)\n^$}
    expect(output.string).to match %r{===> f \(.*spec/fixtures/app/components/f\)\n^$}
    expect(output.string).to match %r{===> g \(.*spec/fixtures/app/components/g\)\n^$}
    expect(output.string).to match %r{===> h \(.*spec/fixtures/app/components/h\)\n^$}
    expect(output.string).to match %r{===> node_manifest \(.*spec/fixtures/app/node_manifest\)\n^$}
  end
end
