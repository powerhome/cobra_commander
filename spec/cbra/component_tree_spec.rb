# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::ComponentTree do
  context "for the fixture app" do
    subject do
      Cbra::ComponentTree.new(AppHelper.root)
    end

    describe "#to_h" do
      it "provides a nested hash of components" do
        expect(subject.to_h).to eql(AppHelper.tree)
      end
    end
  end
end
