# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Package do
  let(:source) { double("source", key: :ruby) }

  subject(:package) do
    CobraCommander::Package.new(source, name: "auth", path: "./", dependencies: [])
  end

  describe "#around_command" do
    it "delegates to its source, forwarding the block" do
      expect(source).to receive(:around_command) { |&block| block.call({ "FOO" => "bar" }) }

      yielded = nil
      package.around_command { |env| yielded = env }

      expect(yielded).to eql("FOO" => "bar")
    end
  end
end
