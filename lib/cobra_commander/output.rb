# frozen_string_literal: true

module CobraCommander
  module Output
    class FlatList
      def initialize(tree)
        @tree = tree
      end

      def to_s
        flatten_tree(@tree)
      end

    private

      def flatten_tree(component)
        component.dependencies.map do |dep|
          [dep.name] + flatten_tree(dep)
        end.flatten.uniq
      end
    end
  end
end
