# frozen_string_literal: true

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
end
