# frozen_string_literal: true

module Darkfang
  # Represents a player account
  class Player
    attr_reader :email, :characters
    attr_accessor :connection, :active_character

    def initialize(data)
      @email = data["email"]
      @password_hash = data["password_hash"]
      @characters = []
      @connection = nil
      @active_character = nil

      # Load characters
      return unless data["characters"] && data["characters"].is_a?(Array)

      data["characters"].each do |character_id|
        load_character(character_id)
      end
    end

    def authenticate(password)
      BCrypt::Password.new(@password_hash) == password
    end

    def load_character(character_id)
      character_file = File.join(Darkfang.root, "data", "characters", "#{character_id}.json")

      return unless File.exist?(character_file)

      begin
        character_data = JSON.parse(File.read(character_file))
        character = Character.new(character_data, self)
        @characters << character

        Darkfang.logger.debug("Loaded character: #{character.name} for player #{@email}")
      rescue StandardError => e
        Darkfang.logger.error("Error loading character #{character_file}: #{e.message}")
      end
    end

    def create_character(name)
      # Validate name
      return "Character name must be at least 3 characters long." if name.empty? || name.length < 3

      # Check if name is already taken
      @characters.each do |character|
        return "You already have a character with that name." if character.name.downcase == name.downcase
      end

      # Create new character
      character_id = SecureRandom.uuid

      character = Character.new({
                                  "id" => character_id,
                                  "name" => name,
                                  "health" => 100,
                                  "max_health" => 100,
                                  "inventory" => [],
                                  "room_id" => "start"
                                }, self)

      @characters << character

      # Save character to file
      Darkfang.game.save_character(character)

      # Update player data
      character_ids = @characters.map(&:id)
      player_data = {
        "email" => @email,
        "password_hash" => @password_hash,
        "characters" => character_ids
      }

      # Save player
      Darkfang.game.save_player(self)

      "Character #{name} created successfully. Use '/select #{@characters.size}' to play as this character."
    end

    def select_character(index)
      if index < 0 || index >= @characters.size
        return "Invalid character number. Use '/select <number>' where number is between 1 and #{@characters.size}."
      end

      # Set active character
      @active_character = @characters[index]

      # Place character in room
      room = Darkfang.world.get_room(@active_character.room_id) || Darkfang.world.start_room
      @active_character.enter_room(room)

      "You are now playing as #{@active_character.name}.\n#{@active_character.look}"
    end

    def send_message(message)
      @connection&.send_message(message)
    end

    def name
      @active_character ? @active_character.name : @email
    end

    def room
      @active_character ? @active_character.room : nil
    end

    def look
      @active_character ? @active_character.look : "You need to select a character first."
    end

    def move(direction)
      @active_character ? @active_character.move(direction) : "You need to select a character first."
    end

    def say(message)
      @active_character ? @active_character.say(message) : "You need to select a character first."
    end

    def shout(message)
      @active_character ? @active_character.shout(message) : "You need to select a character first."
    end

    def show_inventory
      @active_character ? @active_character.show_inventory : "You need to select a character first."
    end

    def take_item(item_name)
      @active_character ? @active_character.take_item(item_name) : "You need to select a character first."
    end

    def drop_item(item_name)
      @active_character ? @active_character.drop_item(item_name) : "You need to select a character first."
    end

    def logout
      @active_character.room.remove_player(@active_character) if @active_character && @active_character.room
      @active_character = nil

      # Show character selection
      message = "You have been logged out of your character.\n"

      if @characters.empty?
        message += "You don't have any characters yet.\n"
        message += "Use '/create <character_name>' to create a new character."
      else
        message += "Your characters:\n"
        @characters.each_with_index do |character, index|
          message += "#{index + 1}. #{character.name}\n"
        end
        message += "Use '/select <number>' to select a character.\n"
        message += "Use '/create <character_name>' to create a new character."
      end

      message
    end

    def to_json(*_args)
      {
        "email" => @email,
        "password_hash" => @password_hash,
        "characters" => @characters.map(&:id)
      }.to_json
    end

    def save
      player_file = File.join(Darkfang.root, "data", "players", "#{@email}.json")
      File.write(player_file, to_json)
    end
  end
end
