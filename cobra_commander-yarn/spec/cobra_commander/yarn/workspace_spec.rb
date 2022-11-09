# frozen_string_literal: true

RSpec.describe CobraCommander::Yarn::Workspace do
  subject { CobraCommander::Yarn::Workspace.new(dummy_path) }
  let(:hr_package) do
    subject.packages.find do |package|
      package.name.eql?("hr-ui")
    end
  end

  it "can load all the internal packages" do
    expect(subject.packages.map(&:name)).to match_array %w[
      auth-ui
      finance-ui
      hr-ui
      sales-ui
    ]
  end

  it "does not include external packages" do
    expect(subject.packages.map(&:name)).to_not include "lol"
  end

  it "loads the internal dependencies of loaded packages" do
    expect(hr_package.dependencies).to match_array %w[auth-ui]
  end

  it "package paths are the root path of a package" do
    expect(hr_package.path.to_s).to eql "#{dummy_path}/components/hr-ui/package.json"
  end
end
