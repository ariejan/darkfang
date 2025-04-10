# frozen_string_literal: true

module Darkfang
  # Base class for automation
  class Automation
    attr_reader :type, :room

    def initialize(data, room)
      @type = data["type"]
      @room = room
    end

    def self.create(data, room)
      case data["type"]
      when "cron"
        CronAutomation.new(data, room)
      else
        Automation.new(data, room)
      end
    end

    def run
      # Base implementation does nothing
    end
  end

  # Automation that runs on a cron schedule
  class CronAutomation < Automation
    def initialize(data, room)
      super
      @cron = data["cron"]
      @command = data["command"]
      @last_run = nil
      
      # Log warning if command is missing
      if @command.nil?
        Darkfang.logger.warn("Missing command in cron automation for room #{room.id}")
      end
    end

    def run
      return unless should_run?
      return if @command.nil?

      # Execute command
      if @command.start_with?("echo ")
        message = @command[5..-1].gsub(/'|"/, "")
        @room.broadcast(message)
      else
        # Other command types could be implemented here
        Darkfang.logger.warn("Unsupported command: #{@command}")
      end

      @last_run = Time.now
    end

    private

    def should_run?
      now = Time.now
      
      # If never run before, run now
      return true unless @last_run
      
      # Parse cron expression
      minute, hour, day, month, weekday = @cron.split(" ")
      
      # Check if it's time to run
      matches_minute?(now, minute) &&
        matches_hour?(now, hour) &&
        matches_day?(now, day) &&
        matches_month?(now, month) &&
        matches_weekday?(now, weekday)
    end

    def matches_minute?(time, minute)
      return true if minute == "*"
      minute.to_i == time.min
    end

    def matches_hour?(time, hour)
      return true if hour == "*"
      hour.to_i == time.hour
    end

    def matches_day?(time, day)
      return true if day == "*"
      day.to_i == time.day
    end

    def matches_month?(time, month)
      return true if month == "*"
      month.to_i == time.month
    end

    def matches_weekday?(time, weekday)
      return true if weekday == "*"
      weekday.to_i == time.wday
    end
  end
end
