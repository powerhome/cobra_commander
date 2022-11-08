# frozen_string_literal: true

require "json"
require "open3"
require "pathname"

module CobraCommander
  module Yarn
    # Yarn workspace components source for an umbrella
    class Workspace < CobraCommander::Source[:js]
      PACKAGE_FILE = "package.json"

      def initialize(root_path)
        @root_path = Pathname.new(root_path)
        super()
      end

      def root
        @root ||= ::CobraCommander::Package.new(
          self,
          name: @root_path.basename,
          path: @root_path.join(PACKAGE_FILE).realpath,
          dependencies: packages.map(&:name)
        )
      end

      def packages
        @packages ||= workspace_data.map do |name, spec|
          ::CobraCommander::Package.new(
            self,
            path: @root_path.join(spec["location"], PACKAGE_FILE).to_s,
            dependencies: spec["workspaceDependencies"].map { |d| untag(d) },
            name: untag(name)
          )
        end
      end

    private

      def workspace_data
        output, = Open3.capture2("yarn workspaces --json info", chdir: @root_path.to_s)
        JSON.parse(JSON.parse(output)["data"])
      end

      def untag(name)
        name&.gsub(%r{^@[\w-]+/}, "")
      end
    end
  end
end
