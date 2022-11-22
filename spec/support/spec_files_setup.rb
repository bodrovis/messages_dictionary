# frozen_string_literal: true

require 'fileutils'

module SpecFilesSetup
  def setup_env!(path, file)
    full_path = "#{RSPEC_ROOT}/dummy/#{path}"

    FileUtils.mkdir_p full_path

    File.open(File.join(full_path, file), 'w+') do |f|
      if /\.ya?ml\z/i.match?(file)
        f.write yaml_data
      else
        f.write json_data
      end
    end
  end

  def clear_env!(path)
    FileUtils.remove_entry("#{RSPEC_ROOT}/dummy/#{path}")
  rescue Errno::EACCES
    puts "Cannot remove #{path}"
  end

  private

  def json_data
    <<~DATA
      {
        "nested": {
          "test": "string"
        },
        "interpolated": "Value is {{a}}"
      }
    DATA
  end

  def yaml_data
    <<~DATA
      test: string
      interpolated: Value is {{a}}
    DATA
  end
end
