module Critique
  module Profiling
    def self.profile(*args)
      base      = args.shift
      offset    = args.shift
      interests = args

      method_name = caller[offset] =~ /`([^']*)'/ && $1
      method_text = label_for(base, method_name)

      Profiler.enter(method_text, interests)
      result = yield # (Profiler)
      Profiler.leave(method_text, interests)

      result
    end

    class Profiler
      class << self
        def info(message)
          Critique.logger.info(['X', padding, message].join)
        end

        def enter(label, interests)
          padding(:+)

          before = stack.push(system_usage.push(label)).last
          found  = (interests.map { |mod| [mod, ObjectSpace.each_object(mod).count].join(':') })

          info(([label, '-->', filler(label)] + pretty(before, found)).join(' '))
        end

        def leave(label, interests)
          found  = (interests.map { |mod| [mod, ObjectSpace.each_object(mod).count].join(':') })
          before = stack.pop
          after  = system_usage

          info(([label, '<--', filler(label)] + pretty(after, found)).join(' '))

          padding(:-)
        end

        private

          def pretty(stats, interests, diff_with = nil)
            used   = stats[0]
            free   = stats[1]
            swap   = stats[2]
            result = [
              sprintf("used: %.2f GB", used / conversion_gb),
              sprintf("free: %.2f GB", free / conversion_gb),
              sprintf("swap: %.2f GB", swap / conversion_gb)
            ]
            result << "interests: #{interests.join(', ')}" if interests.length > 0

            # WIP:
            # if diff_with
            #   current  = used
            #   previous = diff_with[0]
            #   bytes    = (current - previous).to_f
            #   percent  = (bytes / previous) * 100
            # 
            #   result.push(sprintf("delta: %+.2f%", percent))
            # end

            result
          end

          def padding(direction = nil)
            @_padding ||= 0
            @_padding = @_padding.send(direction, 2) if direction
            @_padding = 0 if @_padding < 0
            (' ' * @_padding)
          end

          def filler(text)
            '.' * (73 - text.length - @_padding) # data starting at column 80
          end

          def system_usage
            # installed = `sysctl -n hw.memsize`.to_i / conversion_gb

            stats = `vm_stat`.split("\n")
            used  = add_stats(stats, 'Pages wired down', 'Pages active', 'Pages inactive')
            free  = add_stats(stats, 'Pages free', 'Pages speculative')
            swap  = add_stats(stats, 'Pageouts')

            [used, free, swap]
          end

          def add_stats(*args)
            stats   = args.shift
            keys    = args
            matches = stats.select { |s| keys.any? { |k| s =~ /#{k}:/ } }
            values  = matches.map  { |m| m.split(/\s+/).last.to_i * conversion_paging }.inject(0, :+)
          end

          def conversion_paging
            4096
          end

          def conversion_gb
            (1024 * 1024 * 1000.0)
          end

          def stack
            @_stack ||= []
          end
      end
    end

    private

      def self.label_for(base, method_name)
        [label_class(base), label_sep(base), method_name].join
      end

      def self.label_class(base)
        base.is_a?(Class) ? base.name : base.class.name
      end

      def self.label_sep(base)
        base.is_a?(Class) ? '.' : '#'
      end
  end
end
