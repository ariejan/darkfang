# frozen_string_literal: true

module Darkfang
  class LogAdapter
    attr_accessor :messages, :level

    LOG_LEVELS = {
      debug: ::Logger::DEBUG,
      info: ::Logger::INFO,
      warn: ::Logger::WARN,
      error: ::Logger::ERROR
    }.freeze

    def initialize(level = :info)
      @messages = []
      self.log_level = level
    end

    def log_level=(level)
      @level = level
    end

    def debug(topic, message = nil, &)
      write(:debug, topic, message, &)
    end

    def info(topic, message = nil, &)
      write(:info, topic, message, &)
    end

    def warn(topic, message = nil, &)
      write(:warn, topic, message, &)
    end

    def error(topic, message = nil, &)
      write(:error, topic, message, &)
    end

    def abort_with(topic, message = nil, &)
      error(topic, message, &)
      abort
    end

    # Private: Should this level of message be logged?
    def write_message?(level_of_message)
      LOG_LEVELS.fetch(level) <= LOG_LEVELS.fetch(level_of_message)
    end

    # Private: Format a topic for logging
    def formatted_topic(topic, colon: false)
      "#{topic}#{colon ? ": " : " "}".rjust(20)
    end

    # Private: Format a log message
    def message(topic, message = nil)
      raise ArgumentError, "block or message, not both" if block_given? && message

      message = yield if block_given?
      message = message.to_s.gsub(/\s+/, " ")
      topic = formatted_topic(topic, block_given?)
      out = topic + message
      messages << out
      out
    end

    # Private: Write a log message
    def write(level_of_message, topic, message = nil, &)
      return false unless write_message?(level_of_message)

      log_device(level_of_message).puts(message(topic, message, &))
    end

    def log_device(level)
      case level
      when :warn, :error
        $stderr
      else
        $stdout
      end
    end
  end
end
