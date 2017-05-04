# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::Affected do
  before(:all) do
    @root = AppHelper.root
    @tree = AppHelper.tree
  end

  describe "::new" do
    it "successfully instantiates" do
      expect(described_class.new(@tree, [], @root)).to be_truthy
    end

    context "with no changes" do
      let(:no_changes) do
        described_class.new(@tree, [], @root)
      end

      it "reports no directly affected components" do
        expect(no_changes.directly).to eq []
      end

      it "reports no transitiely affected components" do
        expect(no_changes.transitively).to eq []
      end
    end

    context "with change to top level dependency" do
      let(:with_change_to_a) do
        described_class.new(@tree, ["#{@root}/components/a/Gemfile"], @root)
      end

      it "correctly reports directly affected components" do
        expect(with_change_to_a.directly).to eq [
          { name: "a",
            path: "#{@root}/components/a",
          }
        ]
      end

      it "correctly reports directly affected components" do
        expect(with_change_to_a.transitively).to eq []
      end
    end
  end
end
