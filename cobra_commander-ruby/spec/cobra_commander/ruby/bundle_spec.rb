# frozen_string_literal: true

RSpec.describe CobraCommander::Ruby::Bundle do
  subject { CobraCommander::Ruby::Bundle.new(dummy_path, {}) }
  let(:hr_package) do
    subject.find do |package|
      package.name.eql?("hr")
    end
  end

  it "can load all the unique internal packages" do
    expect(subject.map(&:name)).to match_array %w[
      authn
      authz
      finance
      hr
      sales
    ]
  end

  it "does not include external packages" do
    expect(subject.map(&:name)).to_not include "useragent"
  end

  it "loads the internal dependencies of loaded packages" do
    expect(hr_package.dependencies).to match_array %w[authz authn finance]
  end

  it "package paths are the root path of a package" do
    expect(hr_package.path.to_s).to eql "#{dummy_path}/components/hr"
  end

  describe "#around_command" do
    it "yields BUNDLE_APP_CONFIG pointing at the umbrella .bundle directory" do
      yielded = nil

      subject.around_command { |env| yielded = env }

      expect(yielded).to eql("BUNDLE_APP_CONFIG" => "#{dummy_path}/.bundle")
    end

    it "runs the block with the ambient Bundler environment stripped" do
      Bundler::ORIGINAL_ENV["BUNDLE_GEMFILE"] = "Funny"
      captured = "unset"

      subject.around_command { |_env| captured = ENV.fetch("BUNDLE_GEMFILE", nil) }

      expect(captured).to be_nil
    end

    it "returns the value of the block" do
      expect(subject.around_command { |_env| :result }).to eql(:result)
    end
  end
end
