module ActiveSupport
  module TaggedLogging
    module Formatter
      def tagged(*_args)
        yield
      end

      def push_tags(*_args); end
    end
  end
end
