# frozen_string_literal: true

require "oj"

module CobraCommander
  # Representation of the tree of components and their dependencies
  class ComponentTree
    def initialize(path)
      @root_path = path
    end

    def to_h
      TreeGenerator.new(UMBRELLA_APP_NAME, @root_path).to_h
    end

    # Generates component tree
    class TreeGenerator
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

    private

      def dependencies
        @deps ||= ruby_dependencies + linked_nodes
      end

      def ruby_dependencies
        @ruby_dependencies ||= begin
          return [] unless File.exist?(gemfile_path)
          bundler_definition.dependencies.select do |dep|
            dep.source&.is_a_path? && dep.source.path.to_s != "."
          end
        end
      end

      def linked_nodes
        @nodes ||= begin
          return [] unless File.exist?(package_json_path)
          json = Oj.load(File.read(package_json_path))
          js_format(json["dependencies"])
        end
      end

      def js_format(deps)
        return [] if deps.nil?
        linked_deps = deps.select { |_, v| v.start_with? "link:" }
        linked_deps.map do |_, v|
          relational_path = v.split("link:")[1]
          dep_name = relational_path.split("/")[-1]
          { name: dep_name, path: relational_path }
        end
      end

      def bundler_definition
        ::Bundler::Definition.build(gemfile_path, gemfile_lock_path, nil)
      end

      def package_json_path
        File.join(@root_path, "package.json")
      end

      def gemfile_path
        File.join(@root_path, "Gemfile")
      end

      def gemfile_lock_path
        File.join(@root_path, "Gemfile.lock")
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
