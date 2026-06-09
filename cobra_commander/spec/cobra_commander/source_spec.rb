# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Source do
  describe ".load(path, config, **selector)" do
    it "loads the given sources" do
      memory_source, *others = CobraCommander::Source.load("doesnt_matter", memory: true)

      expect(others.size).to eql 0
      expect(memory_source.count).to eql 4
      expect(memory_source.map(&:key).uniq).to eql [:memory]
    end

    it "handles Errno::ENOENT coming from plugins" do
      memory_source, = CobraCommander::Source.load("doesnt_matter", memory: true)

      expect do
        allow(memory_source).to receive(:packages) { raise Errno::ENOENT }
        memory_source.to_a
      end.to raise_error CobraCommander::Source::Error
    end

    it "loads from all sources when none is given" do
      packages = CobraCommander::Source.load(fixture_file_path("app")).flatten

      expect(packages.count).to eql 9
      expect(packages.map(&:key).uniq).to eql %i[memory stub]
    end

    it "loads the sources with their specific configs" do
      memory_source, = CobraCommander::Source.load(fixture_file_path("app"), { memory: "memory config" },
                                                   memory: true)

      expect(memory_source.config).to eql "memory config"
    end
  end

  describe "#around_command" do
    it "yields an empty env and returns the block's value by default" do
      memory_source, = CobraCommander::Source.load("doesnt_matter", memory: true)
      yielded = nil

      result = memory_source.around_command { |env| yielded = env and :result }

      expect(yielded).to eql({})
      expect(result).to eql(:result)
    end
  end
end
