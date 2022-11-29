# frozen_string_literal: true

require "cobra_commander/package"
require "cobra_commander/registry"

module CobraCommander
  class Source
    Error = Class.new(StandardError)

    include Enumerable
    extend CobraCommander::Registry

    attr_reader :path, :config

    def initialize(path, config)
      @path = Pathname.new(path)
      @config = config || {}
      super()
    end

    def to_ary
      to_a
    end

    def each(&block)
      packages.each(&block)
    rescue Errno::ENOENT => e
      raise Error, e.message
    end

    def self.load(path, config = nil, **selector)
      select(**selector).map do |source|
        source.new(path, config&.dig(source.key))
      end
    end
  end
end
