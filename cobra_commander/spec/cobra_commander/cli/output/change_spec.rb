# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/cli/output/change"

RSpec.describe CobraCommander::CLI::Output::Change do
  let(:umbrella) { fixture_umbrella("app") }

  it "successfully instantiates" do
    expect(CobraCommander::CLI::Output::Change.new(umbrella, "full", "master")).to be_truthy
  end

  describe ".run!" do
    context "with json results" do
      context "with no changes" do
        it "lists no files" do
          changes = CobraCommander::CLI::Output::Change.new(umbrella, "json", "master", changes: [])

          expect { changes.run! }.to output(<<~OUTPUT
            {"changed_files":[],"directly_affected_components":[],"transitively_affected_components":[],"test_scripts":[],"component_names":[],"languages":[]}
          OUTPUT
                                           ).to_stdout
        end
      end

      context "with a change inside a component" do
        it "lists change, affected component, and test" do
          change = CobraCommander::CLI::Output::Change.new(umbrella, "json", "master",
                                                           changes: ["#{umbrella.path}/components/a"])

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{umbrella.path}/components/a"],"directly_affected_components":[{"name":"a","path":["#{umbrella.path}/components/a"],"type":["ruby"]}],"transitively_affected_components":[],"test_scripts":["#{umbrella.path}/components/a/test.sh"],"component_names":["a"],"languages":["ruby"]}
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::CLI::Output::Change.new(umbrella, "json", "master",
                                                           changes: ["#{umbrella.path}/components/e"])

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{umbrella.path}/components/e"],"directly_affected_components":[{"name":"e","path":["#{umbrella.path}/components/e"],"type":["js"]}],"transitively_affected_components":[{"name":"a","path":["#{umbrella.path}/components/a"],"type":["ruby"]},{"name":"b","path":["#{umbrella.path}/components/b"],"type":["ruby","js"]},{"name":"c","path":["#{umbrella.path}/components/c"],"type":["ruby"]},{"name":"d","path":["#{umbrella.path}/components/d"],"type":["ruby"]},{"name":"f","path":["#{umbrella.path}/components/f"],"type":["js"]},{"name":"g","path":["#{umbrella.path}/components/g"],"type":["js"]},{"name":"h","path":["#{umbrella.path}/components/h"],"type":["ruby","js"]},{"name":"node_manifest","path":["#{umbrella.path}/node_manifest"],"type":["js"]}],"test_scripts":["#{umbrella.path}/components/a/test.sh","#{umbrella.path}/components/b/test.sh","#{umbrella.path}/components/c/test.sh","#{umbrella.path}/components/d/test.sh","#{umbrella.path}/components/e/test.sh","#{umbrella.path}/components/f/test.sh","#{umbrella.path}/components/g/test.sh","#{umbrella.path}/components/h/test.sh","#{umbrella.path}/node_manifest/test.sh"],"component_names":["a","b","c","d","e","f","g","h","node_manifest"],"languages":["ruby","js"]}
          OUTPUT
                                          ).to_stdout
        end
      end
    end

    context "with full results" do
      context "with no changes" do
        it "lists no files" do
          changes = CobraCommander::CLI::Output::Change.new(umbrella, "full", "master", changes: [])

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
          change = CobraCommander::CLI::Output::Change.new(umbrella, "full", "master", changes: ["/change"])

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
          change = CobraCommander::CLI::Output::Change.new(umbrella, "full", "master",
                                                           changes: ["#{umbrella.path}/components/a"])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path}/components/a

            <<< Directly affected components >>>
            a - Ruby

            <<< Transitively affected components >>>

            <<< Test scripts to run >>>
            #{umbrella.path}/components/a/test.sh
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with changes inside multiple components" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::CLI::Output::Change.new(
            umbrella, "full", "master",
            changes: ["#{umbrella.path}/components/a", "#{umbrella.path}/components/b"]
          )

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path}/components/a
            #{umbrella.path}/components/b

            <<< Directly affected components >>>
            a - Ruby
            b - Ruby & Js

            <<< Transitively affected components >>>
            a - Ruby
            c - Ruby
            d - Ruby
            f - Js
            g - Js
            h - Ruby & Js
            node_manifest - Js

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
          change = CobraCommander::CLI::Output::Change.new(umbrella, "full", "master",
                                                           changes: ["#{umbrella.path}/components/e"])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path}/components/e

            <<< Directly affected components >>>
            e - Js

            <<< Transitively affected components >>>
            a - Ruby
            b - Ruby & Js
            c - Ruby
            d - Ruby
            f - Js
            g - Js
            h - Ruby & Js
            node_manifest - Js

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
