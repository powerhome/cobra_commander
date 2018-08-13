# frozen_string_literal: true

require "json"

module CobraCommander
  # Representation of the tree of components and their dependencies
  class ComponentTree
    def initialize(path)
      @root_path = path
    end

    def to_h
      Tree.new(UMBRELLA_APP_NAME, @root_path).to_h
    end

    # Generates component tree
    class Tree
      def initialize(name, path, ancestry = Set.new)
        @name = name
        @root_path = path
        @ancestry = ancestry
        @ruby = Ruby.new(path)
        @js = Js.new(path)
        @type = type_of_component
      end

      def to_h
        {
          name: @name,
          path: @root_path,
          type: @type,
          ancestry: @ancestry,
          dependencies: dependencies.map(&method(:dep_representation)),
        }
      end

    private

      def type_of_component
        return "Ruby & JS" if @ruby.gem? && @js.node?
        return "Ruby" if @ruby.gem?
        return "JS" if @js.node?
      end

      def dependencies
        @deps ||= begin
          deps = @ruby.dependencies + @js.dependencies
          deps.sort_by { |dep| dep[:name] }
        end
      end

      def dep_representation(dep)
        full_path = File.expand_path(File.join(@root_path, dep[:path]))
        ancestry = @ancestry + [{ name: @name, path: @root_path, type: @type }]
        self.class.new(dep[:name], full_path, ancestry).to_h
      end

      # Calculates ruby dependencies
      class Ruby
        def initialize(root_path)
          @root_path = root_path
        end

        def dependencies
          @deps ||= begin
            return [] unless gem?
            gems = bundler_definition.dependencies.select { |dep| path?(dep) }
            format(gems)
          end
        end

        def path?(dep)
          if bundler_version_supporting_path_method?
            dep.source&.path? && dep.source.path.to_s != "."
          else
            dep.source&.is_a_path? && dep.source.path.to_s != "."
          end
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

        def bundler_version_supporting_path_method?
          @bundler_version_supporting_path_method ||=
            Gem::Version.new(Bundler::VERSION) >= Gem::Version.new("1.16.0")
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
            format combined_deps(json)
          end
        end

        def format(deps)
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
          Hash(json["dependencies"]).merge(Hash(json["devDependencies"]))
        end
      end
    end
  end
end
