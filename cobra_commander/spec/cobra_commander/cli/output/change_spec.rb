# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/cli/output/change"

RSpec.describe CobraCommander::CLI::Output::Change do
  let(:umbrella) { stub_umbrella("app") }

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
                                                           changes: [umbrella.path.join("hr", "index.html")])

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{umbrella.path.join('hr', 'index.html')}"],"directly_affected_components":[{"name":"hr","path":["#{umbrella.path.join('hr')}"],"type":["stub"]}],"transitively_affected_components":[],"test_scripts":["#{umbrella.path.join('hr', 'test.sh')}"],"component_names":["hr"],"languages":["stub"]}
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::CLI::Output::Change.new(umbrella, "json", "master",
                                                           changes: [umbrella.path.join("auth", "index.html")])

          expect { change.run! }.to output(<<~OUTPUT
            {"changed_files":["#{umbrella.path.join('auth', 'index.html')}"],"directly_affected_components":[{"name":"auth","path":["#{umbrella.path.join('auth')}"],"type":["stub"]}],"transitively_affected_components":[{"name":"directory","path":["#{umbrella.path.join('directory')}"],"type":["stub"]},{"name":"finance","path":["#{umbrella.path.join('finance')}"],"type":["stub"]},{"name":"hr","path":["#{umbrella.path.join('hr')}"],"type":["stub"]},{"name":"sales","path":["#{umbrella.path.join('sales')}"],"type":["stub"]}],"test_scripts":["#{umbrella.path.join('auth', 'test.sh')}","#{umbrella.path.join('directory', 'test.sh')}","#{umbrella.path.join('finance', 'test.sh')}","#{umbrella.path.join('hr', 'test.sh')}","#{umbrella.path.join('sales', 'test.sh')}"],"component_names":["auth","directory","finance","hr","sales"],"languages":["stub"]}
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
          change = CobraCommander::CLI::Output::Change.new(umbrella, "full", "master",
                                                           changes: [Pathname.new("/change")])

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
                                                           changes: [umbrella.path.join("hr", "index.html")])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path.join('hr', 'index.html')}

            <<< Directly affected components >>>
            hr - Stub

            <<< Transitively affected components >>>

            <<< Test scripts to run >>>
            #{umbrella.path.join('hr', 'test.sh')}
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with changes inside multiple components" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::CLI::Output::Change.new(
            umbrella, "full", "master",
            changes: [umbrella.path.join("directory", "index.js"), umbrella.path.join("sales", "index.js")]
          )

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path.join('directory', 'index.js')}
            #{umbrella.path.join('sales', 'index.js')}

            <<< Directly affected components >>>
            directory - Stub
            sales - Stub

            <<< Transitively affected components >>>
            finance - Stub
            hr - Stub
            sales - Stub

            <<< Test scripts to run >>>
            #{umbrella.path.join('directory', 'test.sh')}
            #{umbrella.path.join('finance', 'test.sh')}
            #{umbrella.path.join('hr', 'test.sh')}
            #{umbrella.path.join('sales', 'test.sh')}
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::CLI::Output::Change.new(umbrella, "full", "master",
                                                           changes: [umbrella.path.join("auth", "index.html")])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path.join('auth', 'index.html')}

            <<< Directly affected components >>>
            auth - Stub

            <<< Transitively affected components >>>
            directory - Stub
            finance - Stub
            hr - Stub
            sales - Stub

            <<< Test scripts to run >>>
            #{umbrella.path.join('auth', 'test.sh')}
            #{umbrella.path.join('directory', 'test.sh')}
            #{umbrella.path.join('finance', 'test.sh')}
            #{umbrella.path.join('hr', 'test.sh')}
            #{umbrella.path.join('sales', 'test.sh')}
          OUTPUT
                                          ).to_stdout
        end
      end
    end
  end
end
