# frozen_string_literal: true

require "cobra_commander/dependencies"
require "cobra_commander/component"
require "cobra_commander/umbrella"
require "cobra_commander/version"

# Tools for working with Component Based Rails Apps (see https://cbra.info).
# Includes tools for graphing the components of an app and their relationships, as well as selectively
# testing components based on changes made.
module CobraCommander
  UMBRELLA_APP_NAME = "App"

  def self.umbrella(root_path, yarn: false, bundler: false, name: UMBRELLA_APP_NAME)
    umbrella = Umbrella.new(name, root_path)
    umbrella.add_source(:yarn, Dependencies::Yarn.new(root_path)) unless bundler
    umbrella.add_source(:bundler, Dependencies::Bundler.new(root_path)) unless yarn
    umbrella
  end
end
