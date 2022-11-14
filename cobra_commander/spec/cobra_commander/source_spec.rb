# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Source do
  describe ".load(path, **selector)" do
    it "loads the given sources" do
      memory_source = ::CobraCommander::Source.load("doesnt_matter", memory: true)

      expect(memory_source.size).to eql 3
      expect(memory_source.map(&:key).uniq).to eql [:memory]
    end

    it "handles Errno::ENOENT coming from plugins" do
      expect do
        expect_any_instance_of(::MemorySource).to receive(:each) { raise Errno::ENOENT }
        ::CobraCommander::Source.load("doesnt_matter", memory: true)
      end.to raise_error ::CobraCommander::Source::Error
    end

    it "loads from all sources when none is given" do
      memory_source = ::CobraCommander::Source.load(fixture_file_path("app"))

      expect(memory_source.size).to eql 8
      expect(memory_source.map(&:key).uniq).to eql %i[memory stub]
    end
  end
end
