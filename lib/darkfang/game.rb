# frozen_string_literal: true

module Darkfang
  # Main game logic and state management
  class Game
    attr_reader :players, :commands

    def initialize
      @players = {}
      @commands = {}
      
      # Create data directories if they don't exist
      create_data_directories
      
      # Load players from data files
      load_players
      
      # Register commands
      register_commands
    end

    def create_data_directories
      data_dir = File.join(Darkfang.root, "data")
      players_dir = File.join(data_dir, "players")
      characters_dir = File.join(data_dir, "characters")
      
      [data_dir, players_dir, characters_dir].each do |dir|
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end
    end

    def load_players
      players_dir = File.join(Darkfang.root, "data", "players")
      
      Dir.glob(File.join(players_dir, "*.json")).each do |player_file|
        begin
          player_data = JSON.parse(File.read(player_file))
          player = Player.new(player_data)
          @players[player.email] = player
          
          Darkfang.logger.info("Loaded player: #{player.email}")
        rescue => e
          Darkfang.logger.error("Error loading player #{player_file}: #{e.message}")
        end
      end
    end

    def register_commands
      # Load and register all commands from the commands directory
      Commands.load_commands
      Commands.register_all(self)
    end
    
    def register_command(command)
      @commands[command.name] = command
    end

    def process_command(player, command_name, args)
      command = @commands[command_name]
      
      if command
        command.execute(player, args)
      else
        "Unknown command: #{command_name}. Type /help for a list of commands."
      end
    end

    def authenticate_player(email, password)
      player = @players[email]
      return nil unless player
      
      if player.authenticate(password)
        player
      else
        nil
      end
    end

    def player_exists?(email)
      @players.key?(email)
    end

    def create_player(email, password)
      return nil if player_exists?(email)
      
      player = Player.new({
        "email" => email,
        "password_hash" => BCrypt::Password.create(password),
        "characters" => []
      })
      
      @players[email] = player
      
      # Save player to file
      save_player(player)
      
      player
    end

    def save_player(player)
      players_dir = File.join(Darkfang.root, "data", "players")
      player_file = File.join(players_dir, "#{player.email}.json")
      
      File.write(player_file, player.to_json)
    end

    def save_character(character)
      characters_dir = File.join(Darkfang.root, "data", "characters")
      character_file = File.join(characters_dir, "#{character.id}.json")
      
      File.write(character_file, character.to_json)
    end

    def broadcast(message, except: nil)
      @players.each_value do |player|
        next unless player.connection
        next if player == except
        next unless player.active_character
        
        player.send_message(message)
      end
    end
  end
end
