# frozen_string_literal: true

require "forwardable"

module CobraCommander
  # A package within the
  class Package
    extend Forwardable

    attr_reader :source, :path, :name, :dependencies

    def_delegators :source, :key

    def initialize(source, path:, dependencies:, name:)
      @source = source
      @path = path
      @name = name
      @dependencies = dependencies
    end
  end
end
