# frozen_string_literal: true

require "open3"

require_relative "yarn/package"
require_relative "yarn/package_repo"

module CobraCommander
  module Dependencies
    # Yarn workspace components source for an umbrella
    class YarnWorkspace
      attr_reader :packages

      def initialize(root_path)
        @repo = Yarn::PackageRepo.new
        @root_package = Yarn::Package.new(root_path)
        @repo.load_linked_specs(@root_package)
        load_workspace_packages
      end

      def path
        @root_package.path
      end

      def dependencies
        workspace_spec.keys.map(&method(:untag))
      end

      def components
        @repo.specs.map do |spec|
          { path: spec.path, name: untag(spec.name), dependencies: spec.dependencies.keys.map(&method(:untag)) }
        end
      end

    private

      def load_workspace_packages
        workspace_spec.map do |_name, spec|
          @repo.load_spec File.expand_path(File.join(@root_package.path, "..", spec["location"]))
        end
      end

      def workspace_spec
        @workspace_spec ||= begin
          output, = Open3.capture2("yarn workspaces --json info", chdir: File.dirname(@root_package.path))
          JSON.parse(JSON.parse(output)["data"])
        end
      end

      def untag(name)
        name.gsub(@root_package.project_tag, "")
      end
    end
  end
end
