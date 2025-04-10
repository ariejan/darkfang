# frozen_string_literal: true

module Darkfang
  module Commands
    # Go command - allows player to move in a direction
    class Go < Base
      def initialize
        super("go", "Move in a direction", ["direction"])
      end

      def execute(player, args)
        direction = args[0]
        player.move(direction)
      end

      def self.register(game)
        game.register_command(Go.new)
        
        # Register directional commands
        %w[north south east west up down].each do |direction|
          game.register_command(Direction.new(direction))
          # Also register shorthand (n, s, e, w, u, d)
          game.register_command(Direction.new(direction[0], direction))
        end
      end
    end
    
    # Direction command - shorthand for go command
    class Direction < Base
      def initialize(name, full_direction = nil)
        @direction = full_direction || name
        super(name, "Move #{@direction}")
      end
      
      def execute(player, args)
        player.move(@direction)
      end
    end
  end
end
