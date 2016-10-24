module Ichnite
  class Logger
    attr_reader :logger

    def initialize(logger)
      @logger = logger
      @formatter = Formatters::KeyValue.new
    end

    def log(event, opts = {})
      emit(Ichnite.context(event).merge(opts))
    end

    private

    def emit(data)
      data.each do |k, v|
        data[k] = v.iso8601 if v.respond_to?(:iso8601)
      end
      @logger.info @formatter.call(data)
    end
  end
end
