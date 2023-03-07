# frozen_string_literal: true

module CobraCommander
  module Executor
    module PackageCriteria
      def match_criteria?(package, criteria)
        criteria.all? do |criteria_key, criteria_value|
          criteria_method = "_match_#{criteria_key}?"
          !respond_to?(criteria_method, true) || send(criteria_method, package, criteria_value)
        end
      end

      def _match_depends_on?(package, packages)
        (Array(packages) - package.dependencies).empty?
      end
    end
  end
end
