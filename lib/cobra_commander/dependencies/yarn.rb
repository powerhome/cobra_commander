# frozen_string_literal: true

require "json"
require "open3"

module CobraCommander
  module Dependencies
    # Yarn workspace components source for an umbrella
    class Yarn
      autoload :Package, "cobra_commander/dependencies/yarn/package"

      def initialize(root_path)
        @root_path = root_path
      end

      def path
        @root_path
      end

      def dependencies
        packages.map(&:name)
      end

      def components
        @components ||= packages.map do |package|
          {
            path: package.path,
            name: package.name,
            dependencies: package.dependencies,
          }
        end
      end

    private

      def packages
        @packages ||= begin
          output, = Open3.capture2("yarn workspaces --json info", chdir: @root_path)
          JSON.parse(JSON.parse(output)["data"]).map do |name, spec|
            Package.new(
              File.join(@root_path, spec["location"]),
              name, spec["workspaceDependencies"]
            )
          end
        end
      end
    end
  end
end
