# frozen_string_literal: true

module Darkfang
  module Commands
    # Create command - allows player to create a new character
    class Create < Base
      def initialize
        super("create", "Create a new character", ["name"])
      end

      def execute(player, args)
        name = args.join(" ")
        player.create_character(name)
      end

      def self.register(game)
        game.register_command(Create.new)
      end
    end
    
    # Select command - allows player to select a character
    class Select < Base
      def initialize
        super("select", "Select a character", ["number"])
      end

      def execute(player, args)
        index = args[0].to_i - 1
        player.select_character(index)
      end

      def self.register(game)
        game.register_command(Select.new)
      end
    end
    
    # Logout command - logs out the user and returns them to character selection
    class Logout < Base
      def initialize
        super("logout", "Return to character selection")
      end

      def execute(player, args)
        player.logout
      end

      def self.register(game)
        game.register_command(Logout.new)
      end
    end
  end
end
