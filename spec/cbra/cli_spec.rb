# frozen_string_literal: true

RSpec.describe "cli", type: :aruba do
  describe "checking the version" do
    it "reports the current version" do
      run_simple("cbra version", fail_on_error: true)

      expect(last_command_started).to have_output Cbra::VERSION
    end
  end

  describe "listing components in the tree" do
    it "outputs the tree of components" do
      run_simple("cbra ls spec/fixtures/app", fail_on_error: true)

      expect(last_command_started).to have_output <<~OUTPUT
        App
        ├─┬ a
        │ ├── b
        │ └── c
        └── d
      OUTPUT
    end
  end
end
