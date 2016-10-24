$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ichnite'
require 'logger'
require 'stringio'

require 'minitest/autorun'

class DummyLogger < Logger
  def initialize
    @stringio = StringIO.new
    super @stringio
  end

  def reset
    @stringio.truncate(0)
  end

  def string
    @stringio.string
  end
end

Ichnite.default_logger = Ichnite::Logger.new(DummyLogger.new)

class IchniteTest < Minitest::Test
  def teardown
    # Hack as this wont be possible through the API
    Ichnite.instance_variable_set("@augments", [])
    Ichnite.leave
    Ichnite.default_logger.logger.reset
  end

  def assert_log(expected)
    assert_equal [expected], log_lines
  end

  def assert_logs(*expected)
    assert_equal expected, log_lines
  end

  def log_lines
    log_output.split("\n").map { |line| line.split("INFO -- : ").last }
  end

  def log_output
    Ichnite.default_logger.logger.string
  end
end
