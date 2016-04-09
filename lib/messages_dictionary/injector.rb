module MessagesDictionary
  def self.included(klass)
    klass.class_exec do
      define_singleton_method :has_messages_dictionary do |opts = {}|
        if opts[:messages]
          messages = Dict.new(opts[:messages])
        else
          file = opts[:file] || "#{SpecialString.new(klass.name).snake_case}.yml"
          file = File.expand_path(file, opts[:dir]) if opts[:dir]
          begin
            messages = Dict.new(YAML.load_file(file))
          rescue Errno::ENOENT
            abort "File #{file} does not exist..."
          end
        end
        klass.const_set(:DICTIONARY_CONF, {msgs: messages.extend(Hashie::Extensions::DeepFetch),
                                           output: opts[:output] || STDOUT,
                                           method: opts[:method] || :puts,
                                           transform: opts[:transform]})
      end

      define_method :pretty_output do |key, values = {}, &block|
        msg = klass::DICTIONARY_CONF[:msgs].deep_fetch(*key.to_s.split('.')) do
          raise KeyError, "#{key} cannot be found in the provided file..."
        end
        values.each do |k, v|
          msg.gsub!(Regexp.new('\{\{' + k.to_s + '\}\}'), v.to_s)
        end
        transform = klass::DICTIONARY_CONF[:transform] || block
        transform ?
            transform.call(msg) :
            klass::DICTIONARY_CONF[:output].send(klass::DICTIONARY_CONF[:method].to_sym, msg)
      end
      private :pretty_output
      alias_method :pou, :pretty_output
    end
  end
end