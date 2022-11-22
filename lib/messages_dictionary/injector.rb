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
        __config.load_messages!

        msg = __config.msgs.deep_fetch(*key.to_s.split('.')) do
          handle_key_missing(key)
        end

        __process(
          __replace(msg, values),
          &block
        )
      end

      private :pretty_output
      alias pou pretty_output

      private

      def handle_key_missing(key)
        raise KeyError, "#{key} cannot be found..." if __config.on_key_missing == :raise

        __config.on_key_missing.call(key)
      end

      def __config
        @__config ||= respond_to?(:const_get) ? const_get(:DICTIONARY_CONF) : self.class.const_get(:DICTIONARY_CONF)
      end

      def __replace(msg, values)
        values.each do |k, v|
          msg.gsub!(Regexp.new("\\{\\{#{k}\\}\\}"), v.to_s)
        end

        msg
      end

      def __process(msg, &block)
        transform = block || __config.transform

        if transform
          transform.call(msg)
        else
          __config.output_target.send(__config.output_method, msg)
        end
      end
    end
  end
end
