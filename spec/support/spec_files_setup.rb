# frozen_string_literal: true

require 'fileutils'

module SpecFilesSetup
  def setup_env!(path, file)
    full_path = "./spec/dummy/#{path}"

    FileUtils.mkdir_p full_path

    f = File.new(File.join(full_path, file), 'w+')
    f.write("test: string\ninterpolated: Value is {{a}}")
    f.close
  end

  def clear_env!(path, file)
    FileUtils.remove_entry("./spec/dummy/#{path}/#{file}")
  end
end
