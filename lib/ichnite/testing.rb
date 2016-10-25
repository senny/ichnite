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

    def log(event, data)
      @events << [event, data]
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
      assert_equal [expected], ichnite_log_lines
    end

    def assert_ichnite_logs(*expected)
      assert_equal expected, ichnite_log_lines
    end

    def ichnite_log_lines
      ichnite_logger.output.split("\n").map { |line| line.split("INFO -- : ").last }
    end

    def ichnite_logger
      Ichnite.default_logger
    end
  end
end

Ichnite.default_logger = Ichnite::TestLogger.new
