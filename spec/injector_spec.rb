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

  context "messages" do
    context "outputting" do
      it "uses STDOUT by default" do
        @subject.class_eval do
          has_messages_dictionary messages: {test: 'string'}
        end

        expect(@subject::DICTIONARY_CONF[:output]).to eq(STDOUT)
      end

      it "uses puts method by default" do
        @subject.class_eval do
          has_messages_dictionary messages: {test: 'string'}
        end

        expect(@subject::DICTIONARY_CONF[:method]).to eq(:puts)
      end

      it "allows customizing output and method" do
        output = double('output')
        @subject.class_eval do
          has_messages_dictionary messages: {test: 'string'}, output: output, method: :custom_puts
        end

        object = @subject.new
        expect(output).to receive(:custom_puts).with('string')
        object.send(:pretty_output, :test)
      end

      it "aliases pretty_output as pou" do
        output = double('output')
        @subject.class_eval do
          has_messages_dictionary messages: {test: 'string'}, output: output
        end

        object = @subject.new
        expect(output).to receive(:puts).with('string')
        object.send(:pou, :test)
      end
    end

    context "passed as hash" do
      it "supports nesting" do
        @subject.class_eval do
          has_messages_dictionary messages: {parent: {child: 'child_string'} }
        end

        object = @subject.new
        expect( object.send(:pretty_output, 'parent.child') {|msg| msg} ).to eq('child_string')
      end
    end

    context "passed in file" do
      it "searches file named after class name by default" do
        setup_env!('spec_addons', 'test_class.yml')

        @subject.class_eval do
          has_messages_dictionary
        end

        object = @subject.new
        expect( object.send(:pretty_output, :test) {|msg| msg} ).to eq('string')
        clear_env!('spec_addons')
      end

      it "allows passing path and file" do
        setup_env!('my_test_dir', 'my_test_file.yml')

        @subject.class_eval do
          has_messages_dictionary file: 'my_test_file.yml', dir: 'my_test_dir'
        end

        object = @subject.new
        expect( object.send(:pretty_output, :test) {|msg| msg} ).to eq('string')
        clear_env!('my_test_dir')
      end
    end
  end

  context "error" do
    it "is raised when key is not found" do
      @subject.class_eval do
        has_messages_dictionary messages: {test: 'string'}
      end

      object = @subject.new
      expect( -> {object.send(:pretty_output, :does_not_exist)} ).to raise_error(KeyError)
    end

    it "is raised when file is not found and the program aborts" do
      err = capture_stderr do
        expect(-> {
          @subject.class_eval do
            has_messages_dictionary dir: 'random', file: 'not_exist.yml'
          end
        }).to raise_error(SystemExit)
      end.strip
      expect(err).to eq("File #{File.expand_path('random/not_exist.yml')} does not exist...")
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