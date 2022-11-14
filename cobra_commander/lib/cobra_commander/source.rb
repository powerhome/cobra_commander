# frozen_string_literal: true

require "cobra_commander/registry"

module CobraCommander
  class Source
    Error = Class.new(StandardError)

    include Enumerable
    extend CobraCommander::Registry

    attr_reader :path

    def initialize(path)
      @path = Pathname.new(path)
      super()
    end

    def self.load(path, **selector)
      select(**selector).flat_map { |source| source.new(path).to_a }
    end
  end
end
