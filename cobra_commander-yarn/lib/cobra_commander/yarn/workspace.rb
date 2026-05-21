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
        output, _error, status = Open3.capture3("yarn workspaces list --verbose --json", chdir: path.to_s)
        return parse_modern_output(output) if status.success?

        output, _, status = Open3.capture3("yarn workspaces --json info", chdir: path.to_s)
        raise ::CobraCommander::Source::Error, "Unrecognized yarn workspaces output format" unless status.success?

        JSON.parse(json_data(output))
      end

      def parse_modern_output(output)
        entries = parse_entries(output)
        location_to_name = entries.each_with_object({}) { |e, h| h[e["location"]] = e["name"] }
        entries.each_with_object({}) do |entry, hash|
          hash[entry["name"]] = {
            "location" => entry["location"],
            "workspaceDependencies" => entry["workspaceDependencies"].filter_map { |loc| location_to_name[loc] },
          }
        end
      end

      def parse_entries(output)
        output.lines.filter_map do |line|
          stripped = line.strip
          next if stripped.empty?

          entry = JSON.parse(stripped)
          entry unless entry["location"] == "."
        end
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
