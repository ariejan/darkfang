# frozen_string_literal: true

# stdlib
require "logger"

# gems
require "thor"

# Darkfang internal
require_relative "darkfang/version"
require_relative "darkfang/cli/base"

# Darkfang - the module
module Darkfang
  class Error < StandardError; end

  autoload :LogAdapter, "darkfang/log_adapter"

  class << self
    def env
      ENV["DARKFANG_ENV"] || "development"
    end

    def logger
      @logger = LogAdapter.new((ENV["DARKFANG_LOG_LEVEL"] || :info).to_sym)
    end
  end
end
