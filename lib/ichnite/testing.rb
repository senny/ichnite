require 'stringio'
require 'logger'

module Ichnite
  class TestLogger < Logger
    attr_reader :events

    def initialize
      @events = []
      @buffer = StringIO.new
      super ::Logger.new(@buffer)
    end

    def reset
      @events = []
      @buffer.truncate(0)
    end

    def emit(data)
      event = data.dup
      @events << [event.delete(:event), event]
      super
    end

    def output
      @buffer.string
    end
  end

  module TestHelper
    def teardown
      ichnite_logger.reset
    end

    def assert_ichnite_log(expected)
      assert_equal [expected], ichnite_logs
    end

    def assert_ichnite_logs(*expected)
      assert_equal expected, ichnite_logs
    end

    def assert_ichnite_events(*expected)
      assert_equal expected, ichnite_events
    end

    def ichnite_logs
      ichnite_logger.output.split("\n").map { |line| line.split("INFO -- : ").last }
    end

    def ichnite_events
      ichnite_logger.events
    end

    def ichnite_logger
      Ichnite.default_logger
    end
  end
end

Ichnite.default_logger = Ichnite::TestLogger.new
