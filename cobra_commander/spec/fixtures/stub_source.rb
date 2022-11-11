# frozen_string_literal: true

require "cobra_commander"
require "cobra_commander/source"
require "yaml"

class StubSource < CobraCommander::Source[:stub]
  def packages
    @packages ||= YAML.load_file("#{path}.yml").map do |name, dependencies|
      CobraCommander::Package.new(self, name: name,
                                        path: path.join(name),
                                        dependencies: dependencies || [])
    end
  end
end
