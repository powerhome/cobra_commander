# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/cli/output/change"

RSpec.describe CobraCommander::CLI::Output::Change do
  let(:umbrella) { stub_umbrella("app") }

  it "successfully instantiates" do
    expect(CobraCommander::CLI::Output::Change.new(umbrella, "master")).to be_truthy
  end

  describe ".run!" do
    context "with full results" do
      context "with no changes" do
        it "lists no files" do
          changes = CobraCommander::CLI::Output::Change.new(umbrella, "master", changes: [])

          expect { changes.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>

            <<< Directly affected components >>>

            <<< Transitively affected components >>>
          OUTPUT
                                           ).to_stdout
        end
      end

      context "with a change outside a component" do
        it "just lists single change" do
          change = CobraCommander::CLI::Output::Change.new(umbrella, "master",
                                                           changes: [Pathname.new("/change")])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            /change

            <<< Directly affected components >>>

            <<< Transitively affected components >>>
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with a change inside a component" do
        it "lists change, affected component, and test" do
          change = CobraCommander::CLI::Output::Change.new(umbrella, "master",
                                                           changes: [umbrella.path.join("hr", "index.html")])

          expect { change.run! }.to output(<<~OUTPUT
            <<< Changes since last commit on master >>>
            #{umbrella.path.join('hr', 'index.html')}

            <<< Directly affected components >>>
            hr - Stub

            <<< Transitively affected components >>>
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with changes inside multiple components" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::CLI::Output::Change.new(
            umbrella, "master",
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
          OUTPUT
                                          ).to_stdout
        end
      end

      context "with change inside a very utilized component" do
        it "lists changes, affected components, and tests" do
          change = CobraCommander::CLI::Output::Change.new(umbrella, "master",
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
          OUTPUT
                                          ).to_stdout
        end
      end
    end
  end
end
