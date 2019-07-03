# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Executor do
  let(:tree) { CobraCommander.umbrella_tree(AppHelper.root) }
  subject { CobraCommander::Executor.new(tree) }

  it "executes the given command once on each element of the tree" do
    output = StringIO.new
    subject.exec("pwd", output)

    expect(output.string).to match %r{===> a \(.*spec/fixtures/app/components/a\)
.*spec/fixtures/app/components/a
===> b \(.*spec/fixtures/app/components/b\)
.*spec/fixtures/app/components/b
===> g \(.*spec/fixtures/app/components/g\)
.*spec/fixtures/app/components/g
===> e \(.*spec/fixtures/app/components/e\)
.*spec/fixtures/app/components/e
===> f \(.*spec/fixtures/app/components/f\)
.*spec/fixtures/app/components/f
===> c \(.*spec/fixtures/app/components/c\)
.*spec/fixtures/app/components/c
===> d \(.*spec/fixtures/app/components/d\)
.*spec/fixtures/app/components/d
===> h \(.*spec/fixtures/app/components/h\)
.*spec/fixtures/app/components/h
===> node_manifest \(.*spec/fixtures/app/node_manifest\)
.*spec/fixtures/app/node_manifest}
  end

  it "exposes CURRENT_COMPONENT and CURRENT_COMPONENT_PATH environment variables" do
    output = StringIO.new
    subject.exec("echo $CURRENT_COMPONENT $CURRENT_COMPONENT_PATH", output)

    expect(output.string).to match %r{===> a \(.*spec/fixtures/app/components/a\)
a .*spec/fixtures/app/components/a
===> b \(.*spec/fixtures/app/components/b\)
b .*spec/fixtures/app/components/b
===> g \(.*spec/fixtures/app/components/g\)
g .*spec/fixtures/app/components/g
===> e \(.*spec/fixtures/app/components/e\)
e .*spec/fixtures/app/components/e
===> f \(.*spec/fixtures/app/components/f\)
f .*spec/fixtures/app/components/f
===> c \(.*spec/fixtures/app/components/c\)
c .*spec/fixtures/app/components/c
===> d \(.*spec/fixtures/app/components/d\)
d .*spec/fixtures/app/components/d
===> h \(.*spec/fixtures/app/components/h\)
h .*spec/fixtures/app/components/h
===> node_manifest \(.*spec/fixtures/app/node_manifest\)
node_manifest .*spec/fixtures/app/node_manifest}
  end
end
