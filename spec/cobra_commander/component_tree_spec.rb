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

    describe "when bundle is frozen" do
      # When the application bundle is locked, Bundler represents a components'
      # self-dependency (triggered by `gemspec` in its Gemfile) as a
      # Bundler::Source::Path, rather than a Bundler::Source::Gemspec.
      # This can be confused with a dependency on another component.
      before do
        @original = Bundler.settings.frozen?
        Bundler.settings.set_local(:frozen, true)
      end

      it "#component_dependencies still accurately selects" do
        expect(subject.to_h).to eql(AppHelper.tree)
      end

      after do
        Bundler.settings.set_local(:frozen, @original)
      end
    end
  end
end
