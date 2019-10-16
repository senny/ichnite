module Sidekiq
  module Ichnite
    def self.job_id(msg)
      msg['jid']
    end

    def self.job_class(msg)
      aj_job_class(msg) || msg['class']
    end

    def self.aj_job_class(msg)
      msg['wrapped']
    end

    def self.job_args(msg)
      args = msg['args']
      aj_job_args(args) || args
    end

    def self.aj_job_args(args)
      first_arg = args.first

      # check if the first argument looks like a AJ metadata hash
      if first_arg.is_a?(Hash) && first_arg.key?('arguments')
        first_arg['arguments'].map do |arg|
          if arg.is_a?(Hash) && arg.key?('_aj_globalid')
            arg['_aj_globalid']
          else
            arg
          end
        end
      end
    end

    class ClientMiddleware
      def call(worker_class, msg, queue, _redis_pool)
        context = {
          queue: queue,
          job_id: Sidekiq::Ichnite.job_id(msg),
          job_class: Sidekiq::Ichnite.job_class(msg)
        }
        if at = msg['at']
          context[:scheduled_at] = Time.at(at).utc
          ::Ichnite.log('job_schedule', context)
        else
          context[:args] = Sidekiq::Ichnite.job_args(msg)
          ::Ichnite.log('job_enqueue', context)
        end
        yield
      end
    end

    class ServerMiddleware
      def call(worker, msg, queue)
        ::Ichnite.enter(
          job_id: Sidekiq::Ichnite.job_id(msg),
          job_class: Sidekiq::Ichnite.job_class(msg)) do
          begin
            context = { queue: queue }

            ts = Time.now.to_f
            # We are currently not logging start events.
            # This would most likely blow our SumoLogic limit.
            # start context, ts
            yield
            stop context, msg, ts
          rescue => ex
            error context, msg, ex, ts
            raise ex
          end
        end
      end

      def start(context, _time)
        ::Ichnite.log('job_start', context)
      end

      def error(context, msg, error, start)
        data = context.merge(job_timing(msg, start))
        data.merge!(
          at: :error,
          error: error.class.name,
          message: error.message[/\A.+$/].inspect)
        ::Ichnite.log('job_error', data)
      end

      def stop(context, msg, start)
        data = context.merge(job_timing(msg, start))
        ::Ichnite.log('job_stop', data)
      end

      def job_timing(msg, start)
        # with clock drift this number can become negative.
        # Let's take 0 in this case.
        queued_duration = [0, duration_ms(msg['enqueued_at'], start)].max
        {
          queued_for: queued_duration / 1000,
          duration: duration_ms(start)
        }
      end

      def duration_ms(from, to = Time.now.to_f)
        ((to - from) * 1000).round
      end
    end

  end
end
