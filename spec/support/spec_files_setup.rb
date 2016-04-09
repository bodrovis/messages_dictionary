require 'fileutils'

module SpecFilesSetup
  def setup_env!(path, file)
    FileUtils.mkdir_p(path)
    f = File.new("#{path}/#{file}", 'w+')
    f.write('test: string')
    f.close
  end

  def clear_env!(path)
    FileUtils.remove_entry(path)
  end
end