# frozen_string_literal: true

require 'json'

RSpec.describe MessagesDictionary::Injector do
  let(:dummy) { Class.new { include MessagesDictionary::Injector } }

  context 'with messages' do
    context 'when lazy-loading' do
      it 'loads messages on demand' do
        in_dir 'my_test_file.yml', 'my_test_dir' do
          dummy.class_eval do
            has_messages_dictionary file: 'my_test_file.yml', dir: 'my_test_dir', lazy: true
          end

          expect(dummy::DICTIONARY_CONF.instance_variable_get(:@__loaded)).to be_falsey
          expect(dummy::DICTIONARY_CONF.msgs).to be_nil

          object = dummy.new
          expect(object.send(:pretty_output, :test) { |msg| msg }).to eq('string')
          expect(object.send(:pretty_output, :interpolated, a: 42) { |msg| msg }).to eq('Value is 42')

          expect(dummy::DICTIONARY_CONF.instance_variable_get(:@__loaded)).to be true
          expect(dummy::DICTIONARY_CONF.msgs.keys).to include('test', 'interpolated')
        end
      end
    end

    context 'when outputting' do
      it 'uses STDOUT by default' do
        dummy.class_eval do
          has_messages_dictionary messages: {test: 'string'}
        end

        expect(dummy::DICTIONARY_CONF.output_target).to eq($stdout)
      end

      it 'uses puts method by default' do
        dummy.class_eval do
          has_messages_dictionary messages: {test: 'string'}
        end

        expect(dummy::DICTIONARY_CONF.output_method).to eq(:puts)
      end

      it 'allows customizing output and method' do
        output = instance_double(IO)

        allow(output).to receive(:print)

        dummy.class_eval do
          has_messages_dictionary messages: {test: 'string'}, output: output, method: :print
        end

        object = dummy.new

        object.send(:pretty_output, :test)

        expect(output).to have_received(:print).with('string').exactly(1).time
      end

      it 'aliases pretty_output as pou' do
        output = instance_double(IO)

        allow(output).to receive(:puts)

        dummy.class_eval do
          has_messages_dictionary messages: {test: 'string'}, output: output
        end

        object = dummy.new

        object.send(:pou, :test)

        expect(output).to have_received(:puts).with('string').exactly(1).time
      end

      it 'works for class methods' do
        dummy.class_eval do
          has_messages_dictionary messages: {test: 'string'}

          define_singleton_method :run_klass do
            pou(:test)
          end
        end

        allow($stdout).to receive(:puts).with('string')

        dummy.run_klass

        expect($stdout).to have_received(:puts).exactly(1).time
      end
    end

    context 'when passed as hash' do
      it 'supports nesting' do
        dummy.class_eval do
          has_messages_dictionary messages: {parent: {child: 'child_string'}}
        end

        expect(dummy::DICTIONARY_CONF.instance_variable_get(:@__loaded)).to be true
        object = dummy.new
        expect(object.send(:pretty_output, 'parent.child') { |msg| msg }).to eq('child_string')
      end
    end

    context 'when passed in file' do
      it 'works with anonymous classes' do
        in_dir 'unknown.yml' do
          dummy.class_eval do
            has_messages_dictionary
          end

          object = dummy.new
          expect(object.send(:pretty_output, :test) { |msg| msg }).to eq('string')
        end
      end

      it 'searches file named after class name by default' do
        in_dir 'fake_class.yml' do
          stub_const 'FakeClass', dummy

          FakeClass.class_eval do
            has_messages_dictionary
          end

          object = FakeClass.new
          expect(object.send(:pretty_output, :test) { |msg| msg }).to eq('string')
        end
      end

      it 'allows passing path and file' do
        in_dir 'my_test_file.yml', 'my_test_dir' do
          dummy.class_eval do
            has_messages_dictionary file: 'my_test_file.yml', dir: 'my_test_dir'
          end

          object = dummy.new
          expect(object.send(:pretty_output, :test) { |msg| msg }).to eq('string')
          expect(object.send(:pretty_output, :interpolated, a: 42) { |msg| msg }).to eq('Value is 42')
        end
      end

      it 'allows providing a custom file loader' do
        in_dir 'test_file.json', 'my_dir' do
          dummy.class_eval do
            has_messages_dictionary file: 'test_file.json', dir: 'my_dir',
                                    file_loader: ->(f) { JSON.parse(File.read(f)) }
          end

          object = dummy.new
          expect(object.send(:pretty_output, 'nested.test') { |msg| msg }).to eq('string')
          expect(object.send(:pretty_output, :interpolated, a: 42) { |msg| msg }).to eq('Value is 42')
        end
      end
    end
  end

  context 'with error' do
    it 'is raised when key is not found' do
      dummy.class_eval do
        has_messages_dictionary messages: {test: 'string'}
      end

      key = :does_not_exist

      object = dummy.new
      expect { object.send(:pretty_output, key) }.to raise_error(
        an_instance_of(KeyError).
        and(
          having_attributes(message: "#{key} cannot be found...")
        )
      )
    end

    it 'is allows to use custom missing key handler' do
      dummy.class_eval do
        has_messages_dictionary messages: {test: 'string'},
                                on_key_missing: ->(key) { key.upcase.split('.') },
                                transform: ->(msg) { msg }
      end

      key = 'does.not.exist'

      object = dummy.new
      expect(object.send(:pou, key)).to eq(%w[DOES NOT EXIST])
    end

    it 'is raised when file is not found and the program aborts' do
      expect do
        dummy.class_eval do
          has_messages_dictionary dir: 'random', file: 'not_exist.yml'
        end
      end.to raise_error(
        an_instance_of(Errno::ENOENT).
        and(having_attributes(
              message: "No such file or directory - File #{File.expand_path(
                'random/not_exist.yml'
              )} does not exist..."
            ))
      )
    end
  end

  context 'with transformations' do
    it 'applies per-method transformations' do
      dummy.class_eval do
        has_messages_dictionary messages: {test: 'string'}
      end

      object = dummy.new
      expect(object.send(:pretty_output, :test, &:upcase)).to eq('STRING')
    end

    it 'applies per-class transformations' do
      dummy.class_eval do
        has_messages_dictionary messages: {test: 'string'},
                                transform: ->(msg) { puts msg.upcase }

        define_method :run do
          pou(:test)
        end
      end

      object = dummy.new

      allow($stdout).to receive(:puts).with('STRING')

      object.run

      expect($stdout).to have_received(:puts).exactly(1).time
    end

    it 'per-method takes higher priority than per-class' do
      dummy.class_eval do
        has_messages_dictionary messages: {test: 'string'},
                                transform: ->(msg) { msg.reverse }
      end

      object = dummy.new
      expect(object.send(:pretty_output, :test, &:upcase)).to eq('STRING')
    end
  end
end
