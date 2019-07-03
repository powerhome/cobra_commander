# frozen_string_literal: true

require "cobra_commander/component_tree"

module CobraCommander
  # Represents a dependency tree in a given context, built from a cache
  class CachedComponentTree < ComponentTree
    attr_reader :dependencies

    def self.from_cache_file(cache_file)
      cache = JSON.parse(File.read(cache_file), symbolize_names: true)
      new(cache)
    end

    def initialize(cache)
      super(cache[:name], cache[:path])
      @type = cache[:type]
      @ancestry = Set.new(cache[:ancestry])
      @dependencies = (cache[:dependencies] || []).map do |dep|
        CachedComponentTree.new(dep)
      end
    end
  end
end
