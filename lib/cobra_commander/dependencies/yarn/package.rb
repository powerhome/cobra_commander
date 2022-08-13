# frozen_string_literal: true

require "pathname"

module CobraCommander
  module Dependencies
    class Yarn::Package
      attr_reader :path, :name, :dependencies

      def initialize(path, name, dependencies)
        @path = ::Pathname.new(File.join(path, "package.json")).realpath
        @name = untag(name)
        @dependencies = dependencies.map { |dep| untag(dep) }
      end

    private

      def untag(name)
        name.gsub(%r{^@[\w-]+/}, "")
      end
    end
  end
end
