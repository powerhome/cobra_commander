# frozen_string_literal: true

require "bundler"
require "json"

module CobraCommander
  # Represents a dependency tree in a given context
  class ComponentTree
    attr_reader :name, :path

    def initialize(name, path, ancestry = Set.new)
      @name = name
      @path = path
      @ancestry = ancestry
      @ruby = Ruby.new(path)
      @js = Js.new(path)
      @type = type_of_component
    end

    def flatten
      _flatten(self)
    end

    def subtree(name)
      _subtree(name, self)
    end

    def depends_on?(component_name)
      dependencies.any? do |component|
        component.name == component_name || component.depends_on?(component_name)
      end
    end

    def dependents_of(component_name)
      depends = depends_on?(component_name) ? self : nil
      dependents_below = dependencies.map do |component|
        component.dependents_of(component_name)
      end
      [depends, dependents_below].flatten.compact.uniq(&:name)
    end

    def to_h
      {
        name: @name,
        path: path,
        type: @type,
        ancestry: @ancestry,
        dependencies: dependencies.map(&:to_h),
      }
    end

    def dependencies
      @deps ||= begin
        deps = @ruby.dependencies + @js.dependencies
        deps.sort_by { |dep| dep[:name] }
            .map(&method(:dep_representation))
      end
    end

  private

    def _flatten(component)
      component.dependencies.map do |dep|
        [dep] + _flatten(dep)
      end.flatten.uniq(&:name)
    end

    def _subtree(name, tree)
      return tree if tree.name == name
      tree.dependencies.each do |component|
        presence = _subtree(name, component)
        return presence if presence
      end
      nil
    end

    def type_of_component
      return "Ruby & JS" if @ruby.gem? && @js.node?
      return "Ruby" if @ruby.gem?
      return "JS" if @js.node?
    end

    def dep_representation(dep)
      full_path = File.expand_path(File.join(path, dep[:path]))
      ancestry = @ancestry + [{ name: @name, path: path, type: @type }]
      ComponentTree.new(dep[:name], full_path, ancestry)
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
        workspaces.map do |workspace|
          glob = "#{@root_path}/#{workspace}/package.json"
          workspace_dependencies = Dir.glob(glob)
          workspace_dependencies.map do |wd|
            { name: component_name(wd), path: component_path(wd) }
          end
        end.flatten
      end

    private

      def component_name(dir)
        component_path(dir).split("/")[-1]
      end

      def component_path(dir)
        return dir.split("/package.json")[0] if @root_path == "."

        dir.split(@root_path)[-1].split("/package.json")[0]
      end
    end
  end
end
