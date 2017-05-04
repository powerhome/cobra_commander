# frozen_string_literal: true

require "cbra/cli"
require "cbra/component_tree"
require "cbra/version"
require "cbra/formatted_output"
require "cbra/graph"
require "cbra/change"
require "cbra/affected"

# Tools for working with Component Based Rails Apps (see http://shageman.github.io/cbra.info/).
# Includes tools for graphing the components of an app and their relationships, as well as selectively
# testing components based on changes made.
module Cbra
  UMBRELLA_APP_NAME = "App"
end
