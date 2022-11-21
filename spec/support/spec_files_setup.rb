# frozen_string_literal: true

require 'fileutils'

module SpecFilesSetup
  def setup_env!(path, file)
    full_path = "#{RSPEC_ROOT}/dummy/#{path}"

    FileUtils.mkdir_p full_path

    f = File.new(File.join(full_path, file), 'w+')
    f.write("test: string\ninterpolated: Value is {{a}}")
    f.close
  end

  def clear_env!(path)
    FileUtils.remove_entry("#{RSPEC_ROOT}/dummy/#{path}")
  end
end
