# frozen_string_literal: true

require "cobra_commander"
require "cobra_commander/source"
require "yaml"

class MemorySource < CobraCommander::Source[:memory]
  def each
    yield CobraCommander::Package.new(self, name: "directory",
                                            path: path.join("directory"),
                                            dependencies: [])
    yield CobraCommander::Package.new(self, name: "payroll",
                                            path: path.join("payroll"),
                                            dependencies: ["directory"])
    yield CobraCommander::Package.new(self, name: "finance",
                                            path: path.join("finance"),
                                            dependencies: ["payroll"])
  end
end

class StubSource < CobraCommander::Source[:stub]
  def each
    YAML.load_file("#{path}.yml").each do |name, dependencies|
      yield CobraCommander::Package.new(self, name: name,
                                              path: path.join(name),
                                              dependencies: dependencies || [])
    end
  end
end
