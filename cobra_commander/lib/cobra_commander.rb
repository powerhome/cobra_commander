# frozen_string_literal: true

require "bundler"

require "cobra_commander/affected"
require "cobra_commander/component"
require "cobra_commander/executor"
require "cobra_commander/git_changed"
require "cobra_commander/package"
require "cobra_commander/source"
require "cobra_commander/umbrella"
require "cobra_commander/version"

# Tools for working with Component Based Rails Apps (see https://cbra.info).
# Includes tools for graphing the components of an app and their relationships, as well as selectively
# testing components based on changes made.
module CobraCommander
  def self.umbrella(root_path, **selector)
    Umbrella.new(root_path, **selector)
  end
end
