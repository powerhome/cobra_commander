# frozen_string_literal: true

RSpec.describe CobraCommander::Yarn::Workspace do
  subject { CobraCommander::Yarn::Workspace.new(dummy_path, {}) }
  let(:hr_package) do
    subject.find do |package|
      package.name.eql?("hr-ui")
    end
  end

  it "can load all the internal packages" do
    expect(subject.map(&:name)).to match_array %w[
      auth-ui
      finance-ui
      hr-ui
      sales-ui
    ]
  end

  it "does not include external packages" do
    expect(subject.map(&:name)).to_not include "lol"
  end

  it "loads the internal dependencies of loaded packages" do
    expect(hr_package.dependencies).to match_array %w[auth-ui]
  end

  it "package paths are the root path of a package" do
    expect(hr_package.path.to_s).to eql "#{dummy_path}/components/hr-ui"
  end

  it "throws a CobraCommander::Source::Error when not a valid workspace" do
    workspace = CobraCommander::Yarn::Workspace.new(__dir__, {})

    expect { workspace.to_a }.to raise_error CobraCommander::Source::Error
  end

  context "when using yarn modern (v2+)" do
    let(:modern_ndjson) do
      [
        '{"location":".","name":"dummy","workspaceDependencies":[],"mismatchedWorkspaceDependencies":[]}',
        '{"location":"components/auth-ui","name":"auth-ui","workspaceDependencies":[],"mismatchedWorkspaceDependencies":[]}',
        '{"location":"components/finance-ui","name":"finance-ui","workspaceDependencies":["components/auth-ui"],"mismatchedWorkspaceDependencies":[]}',
        '{"location":"components/hr-ui","name":"hr-ui","workspaceDependencies":["components/auth-ui"],"mismatchedWorkspaceDependencies":[]}',
        '{"location":"components/sales-ui","name":"sales-ui","workspaceDependencies":["components/auth-ui","components/finance-ui"],"mismatchedWorkspaceDependencies":[]}'
      ].join("\n")
    end

    before do
      allow(Open3).to receive(:capture3)
        .with("yarn workspaces list --verbose --json", chdir: dummy_path)
        .and_return([modern_ndjson, "", instance_double(Process::Status, success?: true)])
    end

    it "can load all internal packages" do
      expect(subject.map(&:name)).to match_array %w[auth-ui finance-ui hr-ui sales-ui]
    end

    it "excludes the root workspace" do
      expect(subject.map(&:name)).not_to include "dummy"
    end

    it "resolves path-based dependencies to package names" do
      hr = subject.find { |p| p.name == "hr-ui" }
      expect(hr.dependencies).to match_array %w[auth-ui]
    end

    it "resolves multiple path-based dependencies" do
      sales = subject.find { |p| p.name == "sales-ui" }
      expect(sales.dependencies).to match_array %w[auth-ui finance-ui]
    end
  end

  context "when using yarn v1 (fallback)" do
    let(:v1_inner) do
      JSON.generate(
        "auth-ui" => { "location" => "components/auth-ui", "workspaceDependencies" => [], "mismatchedWorkspaceDependencies" => [] },
        "hr-ui" => { "location" => "components/hr-ui", "workspaceDependencies" => ["auth-ui"], "mismatchedWorkspaceDependencies" => [] }
      )
    end
    let(:v1_output) { JSON.generate("type" => "info", "data" => v1_inner) }

    before do
      allow(Open3).to receive(:capture3)
        .with("yarn workspaces list --verbose --json", chdir: dummy_path)
        .and_return(["", "error", instance_double(Process::Status, success?: false)])
      allow(Open3).to receive(:capture3)
        .with("yarn workspaces --json info", chdir: dummy_path)
        .and_return([v1_output, "", instance_double(Process::Status, success?: true)])
    end

    it "loads packages from v1 output" do
      expect(subject.map(&:name)).to match_array %w[auth-ui hr-ui]
    end

    it "loads workspace dependencies from v1 output" do
      hr = subject.find { |p| p.name == "hr-ui" }
      expect(hr.dependencies).to match_array %w[auth-ui]
    end
  end

  context "when neither yarn version is available" do
    let(:error_output) { JSON.generate("type" => "error", "data" => "Not a workspace") }

    before do
      allow(Open3).to receive(:capture3)
        .with("yarn workspaces list --verbose --json", chdir: dummy_path)
        .and_return(["", "", instance_double(Process::Status, success?: false)])
      allow(Open3).to receive(:capture3)
        .with("yarn workspaces --json info", chdir: dummy_path)
        .and_return(["", error_output, instance_double(Process::Status, success?: false)])
    end

    it "raises CobraCommander::Source::Error" do
      expect { subject.to_a }.to raise_error CobraCommander::Source::Error
    end
  end
end
