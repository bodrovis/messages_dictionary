RSpec.describe MessagesDictionary::Dict do
  subject { described_class.new key: 'value' }

  it "allows indifferent access" do
    expect(subject[:key]).to eq('value')
    expect(subject['key']).to eq('value')
  end
end