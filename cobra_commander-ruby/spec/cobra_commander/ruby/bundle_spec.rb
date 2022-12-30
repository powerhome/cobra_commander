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
end
