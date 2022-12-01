# frozen_string_literal: true

require_relative "./job"

module CobraCommander
  module Executor
    # This is a script job. It can tarket any CobraCommander::Package.
    #
    # If you want to target a Component, you can use Script.for to target
    # individual paths for each given component.
    #
    # @see Script.for
    class Script
      include ::CobraCommander::Executor::Job

      # Returns a set of scripts to be executed on the given commends.
      #
      # If a component has two packages in the same path, only one script for that component will be
      # returned.
      #
      # @param components [Enumerable<CobraCommander::Component>] the target components
      # @param script [String] shell script to run from the directories of the component's packages
      # @return [Array<CobraCommander::Executor::Script>]
      def self.for(components, script)
        components.flat_map(&:packages).uniq(&:path).map do |package|
          new(package, script)
        end
      end

      def initialize(package, script)
        @package = package
        @script = script
      end

      def to_s
        @package.name
      end

      # @see CobraCommander::Executor::Job
      def call
        run_script @script, @package.path
      end
    end
  end
end
