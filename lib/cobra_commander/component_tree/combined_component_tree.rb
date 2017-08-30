# frozen_string_literal: true

require "oj"

module CobraCommander
  class ComponentTree
    # Represents a tree of all component dependencies
    class CombinedComponentTree
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
          dependencies: dependencies.map(&method(:dep_representation)),
        }
      end

      def node_tree
        @node_tree ||= NodeComponentTree.new(UMBRELLA_APP_NAME, @root_path).to_h
      end

      def gem_tree
        @gem_tree ||= GemComponentTree.new(UMBRELLA_APP_NAME, @root_path).to_h
      end

      def js_format(deps)
        linked_deps = deps.select { |_, v| v.start_with? "link:" }
        linked_deps.map do |_, v|
          relational_path = v.split("link:")[1]
          dep_name = relational_path.split("/")[-1]
          { name: dep_name, path: relational_path }
        end
      end

      def gemfile_path
        File.join(@root_path, "Gemfile")
      end

      def gemfile_lock_path
        File.join(@root_path, "Gemfile.lock")
      end

      def bundler_definition
        ::Bundler::Definition.build(gemfile_path, gemfile_lock_path, nil)
      end

      def dependencies
        @deps ||= begin
          deps = []
          deps << component_dependencies if File.exist?(File.join(@root_path, "Gemfile"))
          deps << linked_nodes if File.exist?(File.join(@root_path, "package.json"))
          deps.flatten
        end
      end

      def linked_nodes
        @nodes ||= begin
          package_json = Oj.load(File.read(File.join(@root_path, "package.json")))
          deps = package_json["dependencies"]
          deps.is_a?(Hash) ? js_format(deps) : []
        end
      end

      def component_dependencies
        bundler_definition.dependencies.select do |dep|
          dep.source&.is_a_path? && dep.source.path.to_s != "."
        end
      end

      def dep_representation(dep)
        dep_path, dep_name = extract_dep_info(dep)
        ancestry = @ancestry + [{ name: @name, path: @root_path }]
        self.class.new(dep_name, dep_path, ancestry).to_h
      end

      def extract_dep_info(dep)
        if dep.is_a?(Hash)
          path = File.expand_path(File.join(@root_path, dep[:path]))
          dep_name = dep[:name]
        else
          path = File.expand_path(File.join(@root_path, dep.source.path, dep.name))
          dep_name = dep.name
        end
        [path, dep_name]
      end
    end
  end
end
