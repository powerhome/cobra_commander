# frozen_string_literal: true

require "json"

module CobraCommander
  module Dependencies
    module Yarn
      # Represents an Yarn package.json file
      class Package
        attr_reader :path

        def initialize(path)
          @path = Pathname.new(File.join(path, "package.json")).realpath
        end

        def project_tag
          name.match(%r{^@[\w-]+\/}).to_s
        end

        def name
          json["name"]
        end

        def dependencies
          json.fetch("dependencies", {})
              .merge(json.fetch("devDependencies", {}))
        end

      private

        def json
          @json ||= JSON.parse(File.read(@path))
        end
      end
    end
  end
end
