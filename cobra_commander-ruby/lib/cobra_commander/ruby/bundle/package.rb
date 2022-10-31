# frozen_string_literal: true

module CobraCommander
  module Ruby
    # Calculates ruby bundler dependencies
    class Bundle::Package
      attr_reader :path, :name, :dependencies

      def initialize(spec = nil, path: spec&.loaded_from, name: spec&.name, dependencies: spec&.dependencies)
        @spec = spec
        @path = path
        @name = name
        @dependencies = dependencies&.map(&:name)
      end
    end
  end
end
