# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/git_changed"

RSpec.describe CobraCommander::GitChanged do
  let(:umbrella) { fixture_umbrella("modified-app") }

  it "finds all changed files" do
    changed = CobraCommander::GitChanged.new(umbrella.path, "master")

    expect(changed.to_a).to match_array([
                                          "#{umbrella.path}/components/c/Gemfile",
                                          "#{umbrella.path}/components/f/package.json",
                                        ])
  end
end
