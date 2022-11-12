# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/git_changed"

RSpec.describe CobraCommander::GitChanged do
  let(:umbrella) { stub_umbrella("modified-app", unpack: true) }

  it "finds all changed files" do
    changed = CobraCommander::GitChanged.new(umbrella.path, "main")

    expect(changed.map(&:to_s)).to match_array([umbrella.path.join("finance", "file").to_s])
  end
end
