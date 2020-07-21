# frozen_string_literal: true

module CobraCommander
  module Output
    # Prints a list of components' names sorted alphabetically
    class FlatList
      def initialize(components)
        @components = components
      end

      def to_s
        @components.map(&:name).sort
      end
    end
  end
end
