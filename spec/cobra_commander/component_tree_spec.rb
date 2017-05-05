# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::ComponentTree do
  context "for the fixture app" do
    subject do
      CobraCommander::ComponentTree.new(AppHelper.root)
    end

    describe "#to_h" do
      it "provides a nested hash of components" do
        expect(subject.to_h).to eql(AppHelper.tree)
      end
    end
  end
end
