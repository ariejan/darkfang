# frozen_string_literal: true

module Darkfang
  module Commands
    # Look command - allows player to look around the current room
    class Look < Base
      def initialize
        super("look", "Look around the current room")
      end

      def execute(player, args)
        player.look
      end

      def self.register(game)
        game.register_command(Look.new)
      end
    end
  end
end
