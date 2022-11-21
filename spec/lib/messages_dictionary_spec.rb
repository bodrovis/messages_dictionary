# frozen_string_literal: true

RSpec.describe MessagesDictionary do
  let(:dummy) { Class.new { include MessagesDictionary } }

  it 'includes the necessary methods' do
    dummy.class_eval do
      has_messages_dictionary messages: {parent: {child: 'child_string'}}

      define_method :run do
        pou('parent.child', &:upcase)
      end
    end

    object = dummy.new
    expect(object.send(:pou, 'parent.child') { |msg| msg }).to eq('child_string')
    expect(object.send(:pretty_output, 'parent.child') { |msg| msg }).to eq('child_string')
    expect(object.run).to eq('CHILD_STRING')
  end
end
