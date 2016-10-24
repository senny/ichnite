require "ichnite/version"
require "ichnite/formatters"
require "ichnite/logger"

module Ichnite
  def self.log(event, opts = {})
    default_logger.log(event, opts)
  end

  def self.context(event)
    c = { event: event.to_s }
    @augments.each { |a| c.merge!(a.call) } if defined?(@augments)
    if Thread.current[:ichnite_context]
      c.merge!(Thread.current[:ichnite_context])
    end
    c
  end

  def self.augment(&blk)
    @augments ||= []
    @augments << blk
  end

  def self.enter(context)
    Thread.current[:ichnite_context] ||= {}
    Thread.current[:ichnite_context].merge!(context)

    if block_given?
      begin
        yield
      ensure
        leave(*context.keys)
      end
    end
  end

  def self.leave(*context_keys)
    if context_keys.empty?
      Thread.current[:ichnite_context] = {}
    else
      context_keys.each {|k| Thread.current[:ichnite_context].delete k }
    end
  end

  def self.default_logger
    @default_logger ||=
      if defined?(Rails)
        Ichnite::Logger.new(Rails.logger)
      else
        inner = ::Logger.new($stdout)
        inner.formatter =  proc { |_level, _time, _prog, msg| msg }
        Ichnite::Logger.new(inner)
      end
  end

  def self.default_logger=(logger)
    @default_logger = logger
  end
end
