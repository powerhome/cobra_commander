# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::Affected do
  before(:all) do
    @path = AppHelper.root
    @tree = AppHelper.tree
  end

  describe "::new" do
    let(:no_changes) do
      described_class.new(@tree, [], @path)
    end

    let(:with_changes) do
      # described_class.new(@tree, [stuff], @path)
    end

    it "successfully instantiates" do
      expect(described_class.new(@tree, [], @path)).to be_truthy
    end

    context "with no changes" do
    end
  end
end
