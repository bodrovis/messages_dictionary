# frozen_string_literal: true

module MessagesDictionary
  # This class contains all configuration params
  class Config
    using MessagesDictionary::Utils::StringUtils

    attr_reader :msgs, :output_target, :output_method, :transform, :file,
                :on_key_missing, :file_loader, :__loaded, :__storage, :__klass

    def initialize(opts, klass)
      @__klass = klass.name || 'unknown'
      @__lazy = opts[:lazy]

      opts.key?(:messages) ? hash_storage(opts[:messages]) : file_storage(opts)

      @on_key_missing = opts[:on_key_missing] || :raise
      @output_target = opts[:output] || $stdout
      @output_method = (opts[:method] || :puts).to_sym
      @transform = opts[:transform]

      load_messages
    end

    # This method loads messages from a file but respects the "lazy" option.
    # In other words, it does not load anything if "lazy" is "true".
    # To force messages loading, use the load_messages! method instead.
    def load_messages
      return if @__lazy

      do_load_messages!
    end

    # Loads messages from the file even if "lazy" is "true"
    def load_messages!
      do_load_messages!
    end

    private

    def do_load_messages!
      return if __storage == :hash || __loaded

      begin
        data = file_loader.call file
      rescue Errno::ENOENT
        raise Errno::ENOENT, "File #{file} does not exist..."
      else
        @msgs = MessagesDictionary::Utils::Dict.new data
        @__loaded = true
      end
    end

    def hash_storage(messages)
      @__storage = :hash
      @msgs = MessagesDictionary::Utils::Dict.new messages
      @__loaded = true
    end

    def file_storage(opts)
      @__storage = :file
      @file = opts[:file] || "#{__klass.snakecase}.yml"
      @file = File.expand_path(file, opts[:dir] || '.')
      @file_loader = opts[:file_loader] || ->(file) { YAML.load_file(file) }
    end
  end
end
