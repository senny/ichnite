require 'test_helper'

class LoggerTest < IchniteTest
  def setup
    super
    @output = StringIO.new
    @logger = Ichnite::Logger.new(Logger.new(@output))
  end

  def log_output
    @output.string
  end

  def test_log
    @logger.log(:cat_appear, name: 'Oscar', age: 3)
    assert_log "event=cat_appear name=Oscar age=3"
  end

  def test_special_date_formatting
    time = Time.at(1477312006)
    def time.iso8601 # fake ActiveSupport dependency
      "2016-10-24T14:26:46+02:00"
    end
    @logger.log(:cat_sleep, at: time)
    assert_log "event=cat_sleep at=2016-10-24T14:26:46+02:00"
  end
end
