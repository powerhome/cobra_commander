# frozen_string_literal: true

require "cobra_commander/cli"
require "cobra_commander/cached_component_tree"
require "cobra_commander/calculated_component_tree"
require "cobra_commander/version"
require "cobra_commander/graph"
require "cobra_commander/change"
require "cobra_commander/affected"
require "cobra_commander/output"
require "cobra_commander/executor"

# Tools for working with Component Based Rails Apps (see http://shageman.github.io/cbra.info/).
# Includes tools for graphing the components of an app and their relationships, as well as selectively
# testing components based on changes made.
module CobraCommander
  UMBRELLA_APP_NAME = "App"

  def self.umbrella_tree(path)
    CalculatedComponentTree.new(UMBRELLA_APP_NAME, path)
  end

  def self.tree_from_cache(cache_file)
    CachedComponentTree.from_cache_file(cache_file)
  end
end
