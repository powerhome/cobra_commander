# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/change"

RSpec.describe CobraCommander::Change do
  it "successfully instantiates" do
    expect(CobraCommander::Change.new(fixture_umbrella, "full", "master")).to be_truthy
  end

  describe ".run!" do
    context "with json results" do
      context "with no changes" do
        it "lists no files" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return([])
          changes = CobraCommander::Change.new(fixture_umbrella, "json", "master")

          expect { changes.run! }.to output(<<~OUTPUT
            {"changed_files":[],"directly_affected_components":[],"transitively_affected_components":[],"test_scripts":[],"component_names":[],"languages":{"ruby":false,"javascript":false}}
          OUTPUT
                                           ).to_stdout
        end
      end

      context "with a change inside a component" do
        it "lists change, affected component, and test" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            ["#{fixture_app}/components/a"]
          )
          change = CobraCommander::Change.new(fixture_umbrella, "json", "master")

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{fixture_app}/components/a"],"directly_affected_components":[{"name":"a","path":["#{fixture_app}/components/a"],"type":"Bundler"}],"transitively_affected_components":[],"test_scripts":["#{fixture_app}/components/a/test.sh"],"component_names":["a"],"languages":{"ruby":true,"javascript":false}}
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            ["#{fixture_app}/components/e"]
          )
          change = CobraCommander::Change.new(fixture_umbrella, "json", "master")

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{fixture_app}/components/e"],"directly_affected_components":[{"name":"e","path":["#{fixture_app}/components/e"],"type":"Yarn"}],"transitively_affected_components":[{"name":"a","path":["#{fixture_app}/components/a"],"type":"Bundler"},{"name":"b","path":["#{fixture_app}/components/b"],"type":"Yarn & Bundler"},{"name":"c","path":["#{fixture_app}/components/c"],"type":"Bundler"},{"name":"d","path":["#{fixture_app}/components/d"],"type":"Bundler"},{"name":"f","path":["#{fixture_app}/components/f"],"type":"Yarn"},{"name":"g","path":["#{fixture_app}/components/g"],"type":"Yarn"},{"name":"h","path":["#{fixture_app}/components/h"],"type":"Yarn & Bundler"},{"name":"node_manifest","path":["#{fixture_app}/node_manifest"],"type":"Yarn"}],"test_scripts":["#{fixture_app}/components/a/test.sh","#{fixture_app}/components/b/test.sh","#{fixture_app}/components/c/test.sh","#{fixture_app}/components/d/test.sh","#{fixture_app}/components/e/test.sh","#{fixture_app}/components/f/test.sh","#{fixture_app}/components/g/test.sh","#{fixture_app}/components/h/test.sh","#{fixture_app}/node_manifest/test.sh"],"component_names":["a","b","c","d","e","f","g","h","node_manifest"],"languages":{"ruby":true,"javascript":true}}
          OUTPUT
                                          ).to_stdout
        end
      end
    end

    context "with full results" do
      context "with no changes" do
        it "lists no files" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return([])
          changes = CobraCommander::Change.new(fixture_umbrella, "full", "master")

          expect { changes.run! }.to output(<<~OUTPUT
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
              "/change"
            ]
          )

          expect do
            CobraCommander::Change.new(fixture_umbrella, "full", "master").run!
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
              "#{fixture_app}/components/a"
            ]
          )

          expect do
            CobraCommander::Change.new(fixture_umbrella, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{fixture_app}/components/a

            <<< Directly affected components >>>
            a - Bundler

            <<< Transitively affected components >>>

            <<< Test scripts to run >>>
            #{fixture_app}/components/a/test.sh
          OUTPUT
                       ).to_stdout
        end
      end

      context "with changes inside multiple components" do
        it "lists changes, affected components, and tests" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "#{fixture_app}/components/a",
              "#{fixture_app}/components/b"
            ]
          )

          expect do
            CobraCommander::Change.new(fixture_umbrella, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{fixture_app}/components/a
            #{fixture_app}/components/b

            <<< Directly affected components >>>
            a - Bundler
            b - Yarn & Bundler

            <<< Transitively affected components >>>
            a - Bundler
            c - Bundler
            d - Bundler
            f - Yarn
            g - Yarn
            h - Yarn & Bundler
            node_manifest - Yarn

            <<< Test scripts to run >>>
            #{fixture_app}/components/a/test.sh
            #{fixture_app}/components/b/test.sh
            #{fixture_app}/components/c/test.sh
            #{fixture_app}/components/d/test.sh
            #{fixture_app}/components/f/test.sh
            #{fixture_app}/components/g/test.sh
            #{fixture_app}/components/h/test.sh
            #{fixture_app}/node_manifest/test.sh
          OUTPUT
                       ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          allow_any_instance_of(CobraCommander::Change).to receive(:changes).and_return(
            [
              "#{fixture_app}/components/e"
            ]
          )

          expect do
            CobraCommander::Change.new(fixture_umbrella, "full", "master").run!
          end.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{fixture_app}/components/e

            <<< Directly affected components >>>
            e - Yarn

            <<< Transitively affected components >>>
            a - Bundler
            b - Yarn & Bundler
            c - Bundler
            d - Bundler
            f - Yarn
            g - Yarn
            h - Yarn & Bundler
            node_manifest - Yarn

            <<< Test scripts to run >>>
            #{fixture_app}/components/a/test.sh
            #{fixture_app}/components/b/test.sh
            #{fixture_app}/components/c/test.sh
            #{fixture_app}/components/d/test.sh
            #{fixture_app}/components/e/test.sh
            #{fixture_app}/components/f/test.sh
            #{fixture_app}/components/g/test.sh
            #{fixture_app}/components/h/test.sh
            #{fixture_app}/node_manifest/test.sh
          OUTPUT
                       ).to_stdout
        end
      end
    end
  end
end
