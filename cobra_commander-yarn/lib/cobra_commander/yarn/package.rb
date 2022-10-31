# frozen_string_literal: true

module CobraCommander
  class Yarn::Package
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
