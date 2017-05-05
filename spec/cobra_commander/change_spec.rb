# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Change do
  before(:all) do
    @root = AppHelper.root
    @tree = AppHelper.tree
  end

  before do
    allow_any_instance_of(CobraCommander::ComponentTree).to receive(:to_h).and_return(@tree)
  end

  it "successfully instantiates" do
    expect(described_class.new(@root, "full", "master")).to be_truthy
  end

  describe ".run!" do
    context "with full results" do
      context "with no changes" do
        it "lists no files" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return([])

          expect do
            described_class.new(@root, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>

            <<< Directly affected components >>>

            <<< Transitively affected components >>>

            <<< Test scripts to run >>>
            OUTPUT
                       ).to_stdout
        end
      end

      context "with a change outside a component" do
        it "just lists single change" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(["/change"])

          expect do
            described_class.new(@root, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            /change

            <<< Directly affected components >>>

            <<< Transitively affected components >>>

            <<< Test scripts to run >>>
            OUTPUT
                       ).to_stdout
        end
      end

      context "with a change inside a component" do
        it "lists change, affected component, and test" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(["#{@root}/components/a"])

          expect do
            described_class.new(@root, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{@root}/components/a

            <<< Directly affected components >>>
            a

            <<< Transitively affected components >>>

            <<< Test scripts to run >>>
            #{@root}/components/a/test.sh
            OUTPUT
                       ).to_stdout
        end
      end

      context "with changes inside multiple components" do
        it "lists changes, affected components, and tests" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "#{@root}/components/a",
              "#{@root}/components/b",
            ]
          )

          expect do
            described_class.new(@root, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{@root}/components/a
            #{@root}/components/b

            <<< Directly affected components >>>
            a
            b

            <<< Transitively affected components >>>
            a
            c
            d

            <<< Test scripts to run >>>
            #{@root}/components/a/test.sh
            #{@root}/components/b/test.sh
            #{@root}/components/c/test.sh
            #{@root}/components/d/test.sh
            OUTPUT
                       ).to_stdout
        end
      end
    end
  end
end
