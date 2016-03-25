RSpec.describe MessagesDictionary do
  before :all do
    @subject = SpecAddons::TestClass
    @subject.class_eval do
      include MessagesDictionary
    end
  end

  before :each do
    @subject.class_eval do
      remove_const(:DICTIONARY_CONF) if const_defined?(:DICTIONARY_CONF)
    end
  end

  context "transformations" do
    it "applies per-method transformations" do
      @subject.class_eval do
        has_messages_dictionary messages: {test: 'string'}
      end

      object = @subject.new
      expect( object.send(:pretty_output, :test) {|msg| msg.upcase!} ).to eq('STRING')
    end

    it "applies per-class transformations" do
      @subject.class_eval do
        has_messages_dictionary messages: {test: 'string'},
                                transform: ->(msg) {msg.upcase!}
      end

      object = @subject.new
      expect( object.send(:pretty_output, :test) ).to eq('STRING')
    end
  end
end