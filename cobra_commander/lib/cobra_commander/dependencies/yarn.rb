# frozen_string_literal: true

require "json"
require "open3"
require "pathname"

module CobraCommander
  module Dependencies
    # Yarn workspace components source for an umbrella
    class Yarn
      PACKAGE_FILE = "package.json"

      autoload :Package, "cobra_commander/dependencies/yarn/package"

      def initialize(root_path)
        @root_path = Pathname.new(root_path)
      end

      def root
        @root ||= Package.new(
          path: @root_path.join(PACKAGE_FILE).realpath,
          dependencies: packages.map(&:name)
        )
      end

      def packages
        @packages ||= begin
          output, = Open3.capture2("yarn workspaces --json info", chdir: @root_path.to_s)
          JSON.parse(JSON.parse(output)["data"]).map do |name, spec|
            Package.new(
              path: @root_path.join(spec["location"], PACKAGE_FILE).realpath,
              dependencies: spec["workspaceDependencies"],
              name: name
            )
          end
        end
      end
    end
  end
end
