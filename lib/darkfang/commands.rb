# frozen_string_literal: true

module Darkfang
  # Commands module - loads all commands
  module Commands
    # Load all command files
    def self.load_commands
      require_relative "commands/base"
      require_relative "commands/look"
      require_relative "commands/movement"
      require_relative "commands/communication"
      require_relative "commands/character"
      require_relative "commands/inventory"
      require_relative "commands/help"
    end
    
    # Register all commands with the game
    def self.register_all(game)
      Look.register(game)
      Go.register(game)
      Say.register(game)
      Shout.register(game)
      Create.register(game)
      Select.register(game)
      Logout.register(game)
      Inventory.register(game)
      Take.register(game)
      Drop.register(game)
      Help.register(game)
    end
  end
end
