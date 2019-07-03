# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Change do
  before(:all) do
    @root = AppHelper.root
    @tree = AppHelper.tree
  end

  let(:tree) do
    double(to_h: @tree, path: @root)
  end

  it "successfully instantiates" do
    expect(described_class.new(tree, "full", "master")).to be_truthy
  end

  describe ".run!" do
    context "with json results" do
      context "with no changes" do
        it "lists no files" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return([])

          expect do
            described_class.new(tree, "json", "master").run!
          end.to output(<<~OUTPUT
            {"changed_files":[],"directly_affected_components":[],"transitively_affected_components":[],"test_scripts":[],"component_names":[],"languages":{"ruby":false,"javascript":false}}
            OUTPUT
                       ).to_stdout
        end
      end

      context "with a change inside a component" do
        it "lists change, affected component, and test" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "#{@root}/components/a",
            ]
          )

          expect do
            described_class.new(tree, "json", "master").run!
          end.to output(<<~OUTPUT
            {"changed_files":["#{@root}/components/a"],"directly_affected_components":[{"name":"a","path":"#{@root}/components/a","type":"Ruby"}],"transitively_affected_components":[],"test_scripts":["#{@root}/components/a/test.sh"],"component_names":["a"],"languages":{"ruby":true,"javascript":false}}
            OUTPUT
                       ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "#{@root}/components/e",
            ]
          )

          expect do
            described_class.new(tree, "json", "master").run!
          end.to output(<<~OUTPUT
            {"changed_files":["#{@root}/components/e"],"directly_affected_components":[{"name":"e","path":"#{@root}/components/e","type":"JS"}],"transitively_affected_components":[{"name":"a","path":"#{@root}/components/a","type":"Ruby"},{"name":"b","path":"#{@root}/components/b","type":"Ruby & JS"},{"name":"c","path":"#{@root}/components/c","type":"Ruby"},{"name":"d","path":"#{@root}/components/d","type":"Ruby"},{"name":"g","path":"#{@root}/components/g","type":"JS"},{"name":"node_manifest","path":"#{@root}/node_manifest","type":"JS"}],"test_scripts":["#{@root}/components/a/test.sh","#{@root}/components/b/test.sh","#{@root}/components/c/test.sh","#{@root}/components/d/test.sh","#{@root}/components/e/test.sh","#{@root}/components/g/test.sh","#{@root}/node_manifest/test.sh"],"component_names":["a","b","c","d","e","g","node_manifest"],"languages":{"ruby":true,"javascript":true}}
            OUTPUT
                       ).to_stdout
        end
      end
    end

    context "with full results" do
      context "with no changes" do
        it "lists no files" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return([])

          expect do
            described_class.new(tree, "full", "master").run!
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
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "/change",
            ]
          )

          expect do
            described_class.new(tree, "full", "master").run!
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
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "#{@root}/components/a",
            ]
          )

          expect do
            described_class.new(tree, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{@root}/components/a

            <<< Directly affected components >>>
            a - Ruby

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
            described_class.new(tree, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{@root}/components/a
            #{@root}/components/b

            <<< Directly affected components >>>
            a - Ruby
            b - Ruby & JS

            <<< Transitively affected components >>>
            a - Ruby
            c - Ruby
            d - Ruby
            node_manifest - JS

            <<< Test scripts to run >>>
            #{@root}/components/a/test.sh
            #{@root}/components/b/test.sh
            #{@root}/components/c/test.sh
            #{@root}/components/d/test.sh
            #{@root}/node_manifest/test.sh
            OUTPUT
                       ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "#{@root}/components/e",
            ]
          )

          expect do
            described_class.new(tree, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{@root}/components/e

            <<< Directly affected components >>>
            e - JS

            <<< Transitively affected components >>>
            a - Ruby
            b - Ruby & JS
            c - Ruby
            d - Ruby
            g - JS
            node_manifest - JS

            <<< Test scripts to run >>>
            #{@root}/components/a/test.sh
            #{@root}/components/b/test.sh
            #{@root}/components/c/test.sh
            #{@root}/components/d/test.sh
            #{@root}/components/e/test.sh
            #{@root}/components/g/test.sh
            #{@root}/node_manifest/test.sh
            OUTPUT
                       ).to_stdout
        end
      end
    end
  end
end
