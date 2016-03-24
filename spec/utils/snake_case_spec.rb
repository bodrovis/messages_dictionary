RSpec.describe MessagesDictionary::SpecialString do
  subject { described_class.new('MyTestString') }

  specify "#snake_case" do
    expect(subject.snake_case).to eq('my_test_string')
  end
end