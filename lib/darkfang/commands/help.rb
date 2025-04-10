# frozen_string_literal: true

module Darkfang
  module Commands
    # Help command - shows available commands
    class Help < Base
      def initialize
        super("help", "Show available commands")
      end

      def execute(player, args)
        help_text = "Available commands:\n"
        
        Darkfang.game.commands.values.uniq.sort_by(&:name).each do |command|
          help_text += "  /#{command.name} - #{command.description}\n"
        end
        
        help_text
      end

      def self.register(game)
        game.register_command(Help.new)
      end
    end
  end
end
