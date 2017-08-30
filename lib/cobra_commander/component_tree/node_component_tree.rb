# frozen_string_literal: true

require "oj"

module CobraCommander
  class ComponentTree
    # Represents a tree of javascript components with dependencies extracted via Yarn
    class NodeComponentTree
      def initialize(name, path, ancestry = Set.new)
        @name = name
        @root_path = path
        @ancestry = ancestry
      end

      def to_h
        {
          name: @name,
          path: @root_path,
          ancestry: @ancestry,
          dependencies: linked_nodes.map(&method(:dep_representation)),
        }
      end

    private

      def linked_nodes
        @nodes ||= begin
          package_json = Oj.load(File.read(File.join(@root_path, "package.json")))
          deps = package_json["dependencies"]
          deps.is_a?(Hash) ? format(deps) : []
        end
      end

      def format(deps)
        linked_deps = deps.select { |_, v| v.start_with? "link:" }
        linked_deps.map do |_, v|
          relational_path = v.split("link:")[1]
          name = relational_path.split("/")[-1]
          { name: name, path: relational_path }
        end
      end

      def dep_representation(dep)
        path = File.expand_path(File.join(@root_path, dep[:path]))
        ancestry = @ancestry + [{ name: @name, path: @root_path }]
        self.class.new(dep[:name], path, ancestry).to_h
      end
    end
  end
end
