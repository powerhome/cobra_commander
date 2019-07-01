# frozen_string_literal: true

module CobraCommander
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
