# frozen_string_literal: true

RSpec.describe "cli", type: :aruba do
  let(:file) { "file.txt" }
  let(:content) { "Hello World" }

  describe "checking the version" do
    it "reports the current version" do
      run_simple("cbra version", fail_on_error: true)

      expect(last_command_started).to have_output Cbra::VERSION
    end
  end
end
