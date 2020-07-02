# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Executor do
  let(:umbrella) { CobraCommander.umbrella(AppHelper.root) }
  subject { CobraCommander::Executor.new(umbrella.components) }

  it "executes the given command once on each element of the tree" do
    output = StringIO.new
    subject.exec("pwd", output)

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
end
