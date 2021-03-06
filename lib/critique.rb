require "critique/version"
require "logger"

module Critique
  autoload :Profiling, 'critique/profiling'

  class << self
    def included(base)
      base.extend(ClassMethods)
    end

    def profile(*)
      yield
    end

    def disable!
      module_eval <<-RUBY, __FILE__, __LINE__+1
        def self.profile(*)
          yield
        end
      RUBY
      @_enabled = false
    end

    def enable!
      module_eval <<-RUBY, __FILE__, __LINE__+1
        def self.profile(*args, &block)
          Profiling.profile(*(args.insert(1,2)), &block)
        end
      RUBY
      @_enabled = true
    end

    def enabled?
      @_enabled || false
    end

    def logger=(logger)
      if logger.is_a?(IO) || logger.is_a?(String)
        @_logger = Logger.new(logger)
      else
        @_logger = logger
      end
    end

    def logger
      @_logger ||= Logger.new($stdout)
    end
  end

  module ClassMethods
    def critique(*args, &block)
      Critique.profile(*([self] + args), &block)
    end
  end

  def critique(*args, &block)
    Critique.profile(*([self] + args), &block)
  end
end
