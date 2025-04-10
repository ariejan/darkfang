# frozen_string_literal: true

# stdlib
require "logger"
require "yaml"
require "socket"
require "json"
require "fileutils"
require "securerandom"
require "digest"
require "time"
require "set"

# gems
require "thor"
require "bcrypt"

# Darkfang internal
require_relative "darkfang/version"
require_relative "darkfang/cli/base"

# Darkfang - the module
module Darkfang
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ValidationError < Error; end

  autoload :LogAdapter, "darkfang/log_adapter"
  autoload :Config, "darkfang/config"
  autoload :Server, "darkfang/server"
  autoload :World, "darkfang/world"
  autoload :Room, "darkfang/room"
  autoload :Item, "darkfang/item"
  autoload :Player, "darkfang/player"
  autoload :Character, "darkfang/character"
  autoload :Command, "darkfang/command"
  autoload :Commands, "darkfang/commands"
  autoload :Connection, "darkfang/connection"
  autoload :Game, "darkfang/game"
  autoload :Automation, "darkfang/automation"
  autoload :Validator, "darkfang/validator"

  class << self
    attr_accessor :config, :world, :game

    def env
      ENV["DARKFANG_ENV"] || "development"
    end

    def logger
      @logger ||= LogAdapter.new((ENV["DARKFANG_LOG_LEVEL"] || :info).to_sym)
    end

    def root
      @root ||= Dir.pwd
    end

    def root=(path)
      @root = path
    end

    def load_config
      @config = Config.load
    end

    def init_world
      @world = World.new
      @world.load
    end

    def init_game
      @game = Game.new
    end

    def reset
      @config = nil
      @world = nil
      @game = nil
      @root = nil
      @logger = nil
    end
  end
end
