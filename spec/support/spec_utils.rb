# frozen_string_literal: true

module SpecUtils
  def in_dir(file, path = '')
    return unless block_given?

    setup_env!(path, file)

    initial_path = Dir.getwd

    Dir.chdir "#{RSPEC_ROOT}/dummy"

    yield

    Dir.chdir initial_path

    clear_env!(path)
  end
end
