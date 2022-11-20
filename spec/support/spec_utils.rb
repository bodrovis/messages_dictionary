# frozen_string_literal: true

module SpecUtils
  def capture_stderr
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def in_dir(file, path = '')
    return unless block_given?

    setup_env!(path, file)

    Dir.chdir './spec/dummy'

    yield

    Dir.chdir '../../'

    clear_env!(path)
  end
end
