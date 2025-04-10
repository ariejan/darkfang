# frozen_string_literal: true

module Darkfang
  module Commands
    # Say command - allows player to say something to everyone in the room
    class Say < Base
      def initialize
        super("say", "Say something to everyone in the room", ["message"])
      end

      def execute(player, args)
        message = args.join(" ")
        player.say(message)
      end

      def self.register(game)
        game.register_command(Say.new)
      end
    end
    
    # Shout command - allows player to shout something to everyone in the game
    class Shout < Base
      def initialize
        super("shout", "Shout something to everyone in the game", ["message"])
      end

      def execute(player, args)
        message = args.join(" ")
        player.shout(message)
      end

      def self.register(game)
        game.register_command(Shout.new)
      end
    end
  end
end
