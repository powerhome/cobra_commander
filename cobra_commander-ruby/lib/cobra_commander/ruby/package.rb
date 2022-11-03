# frozen_string_literal: true

module CobraCommander
  module Ruby
    # Calculates ruby bundler dependencies
    class Package
      attr_reader :path, :name, :dependencies

      def initialize(path:, dependencies:, name: nil)
        @path = path
        @name = name
        @dependencies = dependencies
      end
    end
  end
end
