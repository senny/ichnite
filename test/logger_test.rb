require 'test_helper'

class LoggerTest < IchniteTest
  def setup
    super
    output = StringIO.new
    @logger = Ichnite::Logger.new(Logger.new(output))

    # Required by Ichnite::TestHelper
    @logger.define_singleton_method(:output) { output.string }
    @logger.define_singleton_method(:reset) { }
  end

  def ichnite_logger
    @logger
  end

  def test_log
    @logger.log(:cat_appear, name: 'Oscar', age: 3)
    assert_ichnite_log "event=cat_appear name=Oscar age=3"
  end

  def test_special_date_formatting
    time = Time.at(1477312006)
    def time.iso8601 # fake ActiveSupport dependency
      "2016-10-24T14:26:46+02:00"
    end
    @logger.log(:cat_sleep, at: time)
    assert_ichnite_log "event=cat_sleep at=2016-10-24T14:26:46+02:00"
  end
end
