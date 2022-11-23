# frozen_string_literal: true

module MessagesDictionary
  # Main module that injects all the necessary methods in the target class
  module Injector
    def self.included(klass)
      klass.extend ClassMethods
      klass.include InstanceMethods
      klass.extend InstanceMethods
    end

    # Class methods to be defined in the target (where the module was included)
    module ClassMethods
      # rubocop:disable Naming/PredicateName
      # This is the main method that equips the target class
      # with all the necesary goodies
      def has_messages_dictionary(opts = {})
        # rubocop:enable Naming/PredicateName

        const_set :DICTIONARY_CONF, MessagesDictionary::Config.new(opts, self)
      end
    end

    # Instance methods to be defined in the target class
    module InstanceMethods
      # This method will output your messages, perform interpolation,
      # and transformations
      def pretty_output(key, values = {}, &block)
        msg_dict_config.load_messages!

        msg = msg_dict_config.msgs.dig(*key.to_s.split('.'))
        msg = handle_key_missing(key) if msg.nil?

        __process(
          __replace(msg, values),
          &block
        )
      end

      def msg_dict_config
        @msg_dict_config ||= if respond_to?(:const_get)
                               const_get(:DICTIONARY_CONF)
                             else
                               self.class.const_get(:DICTIONARY_CONF)
                             end
      end

      private :pretty_output
      alias pou pretty_output

      private

      def handle_key_missing(key)
        handler = msg_dict_config.on_key_missing

        raise KeyError, "#{key} cannot be found..." if handler == :raise

        handler.call(key)
      end

      def __replace(msg, values)
        values.each do |key, value|
          msg.gsub!(Regexp.new("\\{\\{#{key}\\}\\}"), value.to_s)
        end

        msg
      end

      def __process(msg, &block)
        transform = block || msg_dict_config.transform

        return transform.call(msg) if transform

        msg_dict_config.output_target.send(msg_dict_config.output_method, msg)
      end
    end
  end
end
