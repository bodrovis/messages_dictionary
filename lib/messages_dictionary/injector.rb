# frozen_string_literal: true

module MessagesDictionary
  module Injector
    using MessagesDictionary::Utils::StringUtils

    def self.included(klass)
      klass.class_exec do
        # rubocop:disable Naming/PredicateName
        define_singleton_method :has_messages_dictionary do |opts = {}|
          # rubocop:enable Naming/PredicateName
          if opts[:messages]
            messages = MessagesDictionary::Utils::Dict.new(opts[:messages])
          else
            file = opts[:file] || "#{klass.name.nil? ? 'unknown' : klass.name.snakecase}.yml"
            file = File.expand_path(file, opts[:dir]) if opts[:dir]
            begin
              messages = MessagesDictionary::Utils::Dict.new(YAML.load_file(file))
            rescue Errno::ENOENT
              abort "File #{file} does not exist..."
            end
          end
          klass.const_set(:DICTIONARY_CONF, {msgs: messages.extend(Hashie::Extensions::DeepFetch),
                                             output: opts[:output] || $stdout,
                                             method: opts[:method] || :puts,
                                             transform: opts[:transform]})
        end

        define_method :pretty_output do |key, values = {}, &block|
          msg = klass::DICTIONARY_CONF[:msgs].deep_fetch(*key.to_s.split('.')) do
            raise KeyError, "#{key} cannot be found in the provided file..."
          end
          values.each do |k, v|
            msg.gsub!(Regexp.new("\\{\\{#{k}\\}\\}"), v.to_s)
          end
          transform = block || klass::DICTIONARY_CONF[:transform]
          if transform
            transform.call(msg.dup)
          else
            klass::DICTIONARY_CONF[:output].send(klass::DICTIONARY_CONF[:method].to_sym, msg)
          end
        end
        private :pretty_output
        alias_method :pou, :pretty_output
      end
    end
  end
end
