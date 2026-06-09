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

    # Wraps the execution of commands on this source's packages, letting the
    # source enhance the surrounding process (e.g. Bundler isolation) and
    # contribute environment variables to the command. The base implementation
    # yields an empty env; plugins override it (see CobraCommander::Ruby::Bundle).
    #
    # @yieldparam env [Hash{String => String}] env vars to pass to the command
    # @return the value returned by the block
    def around_command
      yield({})
    end

    def each(&)
      packages.each(&)
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
