# frozen_string_literal: true

module MessagesDictionary
  # Main module that injects all the necessary methods in the target class
  module Injector
    using MessagesDictionary::Utils::StringUtils

    def self.included(klass)
      klass.extend ClassMethods
      klass.include InstanceMethods
    end

    # Class methods to be defined in the target (where the module was included)
    module ClassMethods
      # rubocop:disable Naming/PredicateName
      # This is the main method that equips the target class
      # with all the necesary goodies
      def has_messages_dictionary(opts = {})
        # rubocop:enable Naming/PredicateName
        messages = __powerup(opts.fetch(:messages) { __from_file(opts) })

        const_set(:DICTIONARY_CONF, {msgs: messages,
                                     output: opts[:output] || $stdout,
                                     method: opts[:method] || :puts,
                                     transform: opts[:transform]})
      end

      private

      def __powerup(messages)
        MessagesDictionary::Utils::Dict.new(messages).extend(Hashie::Extensions::DeepFetch)
      end

      def __from_file(opts)
        file = opts[:file] || "#{name.nil? ? 'unknown' : name.snakecase}.yml"
        file = File.expand_path(file, opts[:dir]) if opts[:dir]

        begin
          YAML.load_file(file)
        rescue Errno::ENOENT
          abort "File #{file} does not exist..."
        end
      end
    end

    # Instance methods to be defined in the target class
    module InstanceMethods
      # This method will output your messages, perform interpolation,
      # and transformations
      def pretty_output(key, values = {}, &block)
        msg = self.class::DICTIONARY_CONF[:msgs].deep_fetch(*key.to_s.split('.')) do
          raise KeyError, "#{key} cannot be found in the provided file..."
        end

        __process(
          __replace(msg, values),
          &block
        )
      end

      private :pretty_output
      alias pou pretty_output

      private

      def __replace(msg, values)
        values.each do |k, v|
          msg.gsub!(Regexp.new("\\{\\{#{k}\\}\\}"), v.to_s)
        end

        msg
      end

      def __process(msg, &block)
        transform = block || self.class::DICTIONARY_CONF[:transform]

        if transform
          transform.call(msg)
        else
          self.class::DICTIONARY_CONF[:output].send(self.class::DICTIONARY_CONF[:method].to_sym, msg)
        end
      end
    end
  end
end
