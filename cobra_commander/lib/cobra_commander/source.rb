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
      return all unless selector.values.any?

      all.filter_map do |key, klass|
        [key, klass] if selector[key]
      end
    end
  end

  class Source
    extend Registry

    def self.load(root_path, **selector)
      select(**selector).each do |key, source|
        yield key, source.new(root_path)
      end
    end
  end
end
