# frozen_string_literal: true

RSpec.describe "cli", type: :aruba do
  let(:file) { "file.txt" }
  let(:content) { "Hello World" }

  before(:each) { write_file file, content }

  it { expect(read(file)).to eq [content] }
end
