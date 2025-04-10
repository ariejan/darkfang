# frozen_string_literal: true

module Darkfang
  # Represents a command that can be executed by a player
  class Command
    attr_reader :name, :description, :args

    def initialize(name, description, args = [], &block)
      @name = name
      @description = description
      @args = args
      @block = block
    end

    def execute(player, args)
      @block.call(player, args)
    end
  end
end
