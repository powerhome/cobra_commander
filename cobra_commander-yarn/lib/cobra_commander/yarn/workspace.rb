# frozen_string_literal: true

require "json"
require "open3"
require "pathname"

module CobraCommander
  module Yarn
    # Yarn workspace components source for an umbrella
    class Workspace < CobraCommander::Source[:js]
      def packages
        workspace_data.map do |name, spec|
          ::CobraCommander::Package.new(
            self,
            path: path.join(spec["location"]),
            dependencies: spec["workspaceDependencies"].map { |d| untag(d) },
            name: untag(name)
          )
        end
      end

    private

      def workspace_data
        output, error, status = Open3.capture3("yarn workspaces --json info", chdir: path.to_s)
        raise ::CobraCommander::Source::Error, json_data(error) unless status.success?

        JSON.parse(json_data(output))
      end

      def json_data(json)
        JSON.parse(json)["data"]
      end

      def untag(name)
        name&.gsub(%r{^@[\w-]+/}, "")
      end
    end
  end
end
