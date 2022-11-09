# frozen_string_literal: true

require "json"
require "open3"
require "pathname"

module CobraCommander
  module Yarn
    # Yarn workspace components source for an umbrella
    class Workspace < CobraCommander::Source[:js]
      PACKAGE_FILE = "package.json"

      def packages
        @packages ||= workspace_data.map do |name, spec|
          ::CobraCommander::Package.new(
            self,
            path: path.join(spec["location"], PACKAGE_FILE),
            dependencies: spec["workspaceDependencies"].map { |d| untag(d) },
            name: untag(name)
          )
        end
      end

    private

      def workspace_data
        output, = Open3.capture2("yarn workspaces --json info", chdir: path.to_s)
        JSON.parse(JSON.parse(output)["data"])
      end

      def untag(name)
        name&.gsub(%r{^@[\w-]+/}, "")
      end
    end
  end
end
