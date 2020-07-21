# frozen_string_literal: true

require_relative "output/flat_list"
require_relative "output/ascii_tree"

module CobraCommander
  # Module for pretty printing dependency trees
  module Output
    def self.print(component, format)
      output = format == "list" ? Output::FlatList.new(component.deep_dependencies) : Output::AsciiTree.new(component)
      puts output.to_s
    end
  end
end
