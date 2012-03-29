require "critique/version"
require "logger"

module Critique
  autoload :Profiling, 'critique/profiling'

  class << self
    def included(base)
      base.extend(ClassMethods)
    end

    def profile(base)
      yield
    end

    def disable!
      module_eval("def self.profile(base) ; yield ; end")
    end

    def enable!
      module_eval("def self.profile(base, &block) ; Profiling.profile(base, 2, &block) ; end")
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
    def critique(&block)
      Critique.profile(self, &block)
    end
  end

  def critique(&block)
    Critique.profile(self, &block)
  end
end
