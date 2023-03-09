# frozen_string_literal: true

module CobraCommander
  # Calculates directly & transitively affected components
  # Takes a list of changes, and resolves all components affected
  #
  class Affected
    include Enumerable

    def initialize(umbrella, changes)
      @umbrella = umbrella
      @changes = changes
    end

    def each(&block)
      (directly | transitively).sort_by(&:name).each(&block)
    end

    def directly
      @directly ||= @changes.filter_map { |path| @umbrella.resolve(path) }
                            .uniq.sort_by(&:name)
    end

    def transitively
      @transitively ||= directly.flat_map(&:deep_dependents)
                                .uniq.sort_by(&:name)
    end
  end
end
