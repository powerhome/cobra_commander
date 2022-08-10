# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/change"

RSpec.describe CobraCommander::Change do
  let(:umbrella) { fixture_umbrella("app") }

  it "successfully instantiates" do
    expect(CobraCommander::Change.new(umbrella, "full", "master")).to be_truthy
  end

  describe ".run!" do
    context "with json results" do
      context "with no changes" do
        it "lists no files" do
          changes = CobraCommander::Change.new(umbrella, "json", "master", changes: [])

          expect { changes.run! }.to output(<<~OUTPUT
            {"changed_files":[],"directly_affected_components":[],"transitively_affected_components":[],"test_scripts":[],"component_names":[],"languages":{"ruby":false,"javascript":false}}
          OUTPUT
                                           ).to_stdout
        end
      end

      context "with a change inside a component" do
        it "lists change, affected component, and test" do
          change = CobraCommander::Change.new(umbrella, "json", "master", changes: ["#{umbrella.path}/components/a"])

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{umbrella.path}/components/a"],"directly_affected_components":[{"name":"a","path":["#{umbrella.path}/components/a"],"type":"Bundler"}],"transitively_affected_components":[],"test_scripts":["#{umbrella.path}/components/a/test.sh"],"component_names":["a"],"languages":{"ruby":true,"javascript":false}}
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::Change.new(umbrella, "json", "master", changes: ["#{umbrella.path}/components/e"])

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{umbrella.path}/components/e"],"directly_affected_components":[{"name":"e","path":["#{umbrella.path}/components/e"],"type":"Yarn"}],"transitively_affected_components":[{"name":"a","path":["#{umbrella.path}/components/a"],"type":"Bundler"},{"name":"b","path":["#{umbrella.path}/components/b"],"type":"Yarn & Bundler"},{"name":"c","path":["#{umbrella.path}/components/c"],"type":"Bundler"},{"name":"d","path":["#{umbrella.path}/components/d"],"type":"Bundler"},{"name":"f","path":["#{umbrella.path}/components/f"],"type":"Yarn"},{"name":"g","path":["#{umbrella.path}/components/g"],"type":"Yarn"},{"name":"h","path":["#{umbrella.path}/components/h"],"type":"Yarn & Bundler"},{"name":"node_manifest","path":["#{umbrella.path}/node_manifest"],"type":"Yarn"}],"test_scripts":["#{umbrella.path}/components/a/test.sh","#{umbrella.path}/components/b/test.sh","#{umbrella.path}/components/c/test.sh","#{umbrella.path}/components/d/test.sh","#{umbrella.path}/components/e/test.sh","#{umbrella.path}/components/f/test.sh","#{umbrella.path}/components/g/test.sh","#{umbrella.path}/components/h/test.sh","#{umbrella.path}/node_manifest/test.sh"],"component_names":["a","b","c","d","e","f","g","h","node_manifest"],"languages":{"ruby":true,"javascript":true}}
          OUTPUT
                                          ).to_stdout
        end
      end
    end

    context "with full results" do
      context "with no changes" do
        it "lists no files" do
          changes = CobraCommander::Change.new(umbrella, "full", "master", changes: [])

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
          change = CobraCommander::Change.new(umbrella, "full", "master", changes: ["/change"])

          expect { change.run! }.to output(<<~OUTPUT
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
          change = CobraCommander::Change.new(umbrella, "full", "master", changes: ["#{umbrella.path}/components/a"])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path}/components/a

            <<< Directly affected components >>>
            a - Bundler

            <<< Transitively affected components >>>

            <<< Test scripts to run >>>
            #{umbrella.path}/components/a/test.sh
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with changes inside multiple components" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::Change.new(
            umbrella, "full", "master",
            changes: ["#{umbrella.path}/components/a", "#{umbrella.path}/components/b"]
          )

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path}/components/a
            #{umbrella.path}/components/b

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
            #{umbrella.path}/components/a/test.sh
            #{umbrella.path}/components/b/test.sh
            #{umbrella.path}/components/c/test.sh
            #{umbrella.path}/components/d/test.sh
            #{umbrella.path}/components/f/test.sh
            #{umbrella.path}/components/g/test.sh
            #{umbrella.path}/components/h/test.sh
            #{umbrella.path}/node_manifest/test.sh
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::Change.new(umbrella, "full", "master", changes: ["#{umbrella.path}/components/e"])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path}/components/e

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
            #{umbrella.path}/components/a/test.sh
            #{umbrella.path}/components/b/test.sh
            #{umbrella.path}/components/c/test.sh
            #{umbrella.path}/components/d/test.sh
            #{umbrella.path}/components/e/test.sh
            #{umbrella.path}/components/f/test.sh
            #{umbrella.path}/components/g/test.sh
            #{umbrella.path}/components/h/test.sh
            #{umbrella.path}/node_manifest/test.sh
          OUTPUT
                                          ).to_stdout
        end
      end
    end
  end
end
