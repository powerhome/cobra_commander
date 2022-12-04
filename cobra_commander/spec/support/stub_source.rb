# frozen_string_literal: true

require "cobra_commander"
require "cobra_commander/source"
require "yaml"

class MemorySource < CobraCommander::Source[:memory]
  def packages
    [CobraCommander::Package.new(self, name: "directory",
                                       path: path.join("directory"),
                                       dependencies: []),
     CobraCommander::Package.new(self, name: "payroll",
                                       path: path.join("payroll"),
                                       dependencies: ["directory"]),
     CobraCommander::Package.new(self, name: "finance",
                                       path: path.join("finance"),
                                       dependencies: ["payroll"]),
     CobraCommander::Package.new(self, name: "finance_models",
                                       path: path.join("finance_models"),
                                       dependencies: ["finance"])]
  end
end

class StubSource < CobraCommander::Source[:stub]
  def packages
    YAML.load_file("#{path}.yml").map do |name, dependencies|
      CobraCommander::Package.new(self, name: name,
                                        path: path.join(name),
                                        dependencies: dependencies || [])
    end
  end
end
