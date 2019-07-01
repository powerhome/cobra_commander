# frozen_string_literal: true

module CobraCommander
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
end
