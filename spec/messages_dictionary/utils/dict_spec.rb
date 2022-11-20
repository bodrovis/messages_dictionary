# frozen_string_literal: true

RSpec.describe MessagesDictionary::Utils::Dict do
  let(:dummy) { described_class.new key: 'value' }

  it 'allows indifferent access' do
    expect(dummy[:key]).to eq('value')
    expect(dummy['key']).to eq('value')
  end
end
