# frozen_string_literal: true

module Darkfang
  module Commands
    # Inventory command - allows player to view their inventory
    class Inventory < Base
      def initialize
        super("inventory", "View your inventory")
      end

      def execute(player, args)
        player.show_inventory
      end

      def self.register(game)
        game.register_command(Inventory.new)
        # Register shorthand
        game.register_command(InventoryShorthand.new)
      end
    end
    
    # Inventory shorthand command
    class InventoryShorthand < Base
      def initialize
        super("i", "View your inventory")
      end

      def execute(player, args)
        player.show_inventory
      end
    end
    
    # Take command - allows player to take an item
    class Take < Base
      def initialize
        super("take", "Take an item", ["item"])
      end

      def execute(player, args)
        item_name = args.join(" ")
        player.take_item(item_name)
      end

      def self.register(game)
        game.register_command(Take.new)
      end
    end
    
    # Drop command - allows player to drop an item
    class Drop < Base
      def initialize
        super("drop", "Drop an item", ["item"])
      end

      def execute(player, args)
        item_name = args.join(" ")
        player.drop_item(item_name)
      end

      def self.register(game)
        game.register_command(Drop.new)
      end
    end
  end
end
