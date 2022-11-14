# frozen_string_literal: true

require "cobra_commander/package"

module CobraCommander
  module Registry
    def [](key)
      Class.new(self) do
        define_singleton_method(:key) { key }
        define_method(:key) { key }

        def self.inherited(base)
          super
          superclass.all[key] = base
        end
      end
    end

    def all
      @all ||= {}
    end

    def select(**selector)
      return all.values unless selector.values.any?

      all.filter_map do |key, klass|
        klass if selector[key]
      end
    end
  end

  class Source
    include Enumerable
    extend Registry

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
