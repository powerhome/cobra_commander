# frozen_string_literal: true

require "cobra_commander/component_tree"
require "open3"

module CobraCommander
  # Represents a dependency tree in a given context
  class CalculatedComponentTree < ComponentTree
    attr_reader :name, :path

    def initialize(name, path, ancestry = Set.new)
      super(name, path)
      @ancestry = ancestry
      @ruby = Ruby.new(path)
      @js = Js.new(path)
      @type = type_of_component
    end

    def dependencies
      @deps ||= begin
        deps = @ruby.dependencies + @js.dependencies
        deps.sort_by { |dep| dep[:name] }
            .map(&method(:dep_representation))
      end
    end

  private

    def type_of_component
      return "Ruby & JS" if @ruby.gem? && @js.node?
      return "Ruby" if @ruby.gem?
      return "JS" if @js.node?
    end

    def dep_representation(dep)
      full_path = File.expand_path(File.join(path, dep[:path]))
      ancestry = @ancestry + [{ name: @name, path: path, type: @type }]
      CalculatedComponentTree.new(dep[:name], full_path, ancestry)
    end

    # Calculates ruby dependencies
    class Ruby
      def initialize(root_path)
        @root_path = root_path
      end

      def dependencies
        @deps ||= begin
          return [] unless gem?
          gems = bundler_definition.dependencies.select { |dep| path?(dep.source) }
          format(gems)
        end
      end

      def path?(source)
        return if source.nil?
        source_has_path = source.respond_to?(:path?) ? source.path? : source.is_a_path?
        source_has_path && source.path.to_s != "."
      end

      def format(deps)
        deps.map do |dep|
          path = File.join(dep.source.path, dep.name)
          { name: dep.name, path: path }
        end
      end

      def gem?
        @gem ||= File.exist?(gemfile_path)
      end

      def bundler_definition
        ::Bundler::Definition.build(gemfile_path, gemfile_lock_path, nil)
      end

      def gemfile_path
        File.join(@root_path, "Gemfile")
      end

      def gemfile_lock_path
        File.join(@root_path, "Gemfile.lock")
      end
    end

    # Calculates js dependencies
    class Js
      def initialize(root_path)
        @root_path = root_path
      end

      def dependencies
        @deps ||= begin
          return [] unless node?
          json = JSON.parse(File.read(package_json_path))
          combined_deps(json)
        end
      end

      def format_dependencies(deps)
        return [] if deps.nil?
        linked_deps = deps.select { |_, v| v.start_with? "link:" }
        linked_deps.map do |_, v|
          relational_path = v.split("link:")[1]
          dep_name = relational_path.split("/")[-1]
          { name: dep_name, path: relational_path }
        end
      end

      def node?
        @node ||= File.exist?(package_json_path)
      end

      def package_json_path
        File.join(@root_path, "package.json")
      end

      def combined_deps(json)
        worskpace_dependencies = build_workspaces(json["workspaces"])
        dependencies = format_dependencies Hash(json["dependencies"]).merge(Hash(json["devDependencies"]))
        (dependencies + worskpace_dependencies).uniq
      end

      def build_workspaces(workspaces)
        return [] if workspaces.nil?

        yarn_workspaces = read_workspaces
        yarn_workspaces.map do |_, component|
          { name: component["location"].split("/")[-1], path: component["location"] }
        end
      end

    private

      def read_workspaces
        output, = Open3.capture2("yarn workspaces info", chdir: @root_path)
        striped_output = output.lines[1..-2].join
        JSON.parse(striped_output)
      end
    end
  end
end
