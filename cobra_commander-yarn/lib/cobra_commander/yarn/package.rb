# frozen_string_literal: true

module CobraCommander
  module Yarn
    # Yarn Package
    class Package
      attr_reader :path, :name, :dependencies

      def initialize(path:, dependencies:, name: nil)
        @path = path
        @name = untag(name)
        @dependencies = dependencies.map { |dep| untag(dep) }
      end

    private

      def untag(name)
        name&.gsub(%r{^@[\w-]+/}, "")
      end
    end
  end
end
