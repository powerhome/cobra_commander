# frozen_string_literal: true

require "spec_helper"

RSpec.describe CobraCommander::Component do
  let(:umbrella) { double("umbrella") }
  subject(:component) { described_class.new(umbrella, "finance") }

  describe "#around_command" do
    def package_from(name, source)
      CobraCommander::Package.new(source, name: name, path: "./", dependencies: [])
    end

    # A source double whose #around_command yields the given env (like a real
    # source) and records its invocation order.
    def source_yielding(key, env, order: nil, marker: nil)
      double(key.to_s, key: key).tap do |source|
        allow(source).to receive(:around_command) do |&block|
          order << marker if order
          block.call(env)
        end
      end
    end

    it "yields an empty env when no package contributes one" do
      component.add_package(package_from("a", source_yielding(:a, {})))

      yielded = nil
      result = component.around_command { |env| yielded = env and :ran }

      expect(yielded).to eql({})
      expect(result).to eql(:ran)
    end

    it "yields the merged env of each distinct source" do
      component.add_package(package_from("a", source_yielding(:a, { "A" => "1" })))
      component.add_package(package_from("b", source_yielding(:b, { "B" => "2" })))

      yielded = nil
      component.around_command { |env| yielded = env }

      expect(yielded).to eql("A" => "1", "B" => "2")
    end

    it "lets later sources win on key collisions" do
      component.add_package(package_from("a", source_yielding(:a, { "A" => "1" })))
      component.add_package(package_from("b", source_yielding(:b, { "A" => "2" })))

      yielded = nil
      component.around_command { |env| yielded = env }

      expect(yielded).to eql("A" => "2")
    end

    it "nests each source's around_command around the block" do
      order = []
      component.add_package(package_from("a", source_yielding(:a, {}, order: order, marker: :s1)))
      component.add_package(package_from("b", source_yielding(:b, {}, order: order, marker: :s2)))

      component.around_command { order << :inner }

      expect(order).to eq(%i[s1 s2 inner])
    end

    it "invokes a shared source's around_command only once" do
      source = source_yielding(:a, {})
      component.add_package(package_from("a", source))
      component.add_package(package_from("b", source))

      component.around_command { |_env| :ran }

      expect(source).to have_received(:around_command).once
    end
  end
end
