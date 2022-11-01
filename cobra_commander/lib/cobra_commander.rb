# frozen_string_literal: true

require "cobra_commander/ruby"
require "cobra_commander/yarn"

require "cobra_commander/component"
require "cobra_commander/umbrella"
require "cobra_commander/version"

# Tools for working with Component Based Rails Apps (see https://cbra.info).
# Includes tools for graphing the components of an app and their relationships, as well as selectively
# testing components based on changes made.
module CobraCommander
  def self.umbrella(root_path, yarn: false, bundler: false)
    umbrella = Umbrella.new(root_path)
    umbrella.add_source(:yarn, ::CobraCommander::Yarn::Workspace.new(root_path)) unless bundler
    umbrella.add_source(:bundler, ::CobraCommander::Ruby::Bundle.new(root_path)) unless yarn
    umbrella
  end
end
