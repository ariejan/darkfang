# frozen_string_literal: true

module Darkfang
  # Represents a player character in the game
  class Character
    attr_reader :id, :name, :health, :max_health, :inventory, :room_id, :room

    def initialize(data, player)
      @id = data["id"]
      @name = data["name"]
      @health = data["health"] || 100
      @max_health = data["max_health"] || 100
      @inventory = []
      @room_id = data["room_id"] || "start"
      @room = nil
      @player = player
      
      # Load inventory items
      if data["inventory"] && data["inventory"].is_a?(Array)
        data["inventory"].each do |item_data|
          @inventory << Item.new(item_data["id"], item_data["attributes"])
        end
      end
    end

    def enter_room(room)
      # Leave current room if any
      @room&.remove_player(@player)
      
      # Enter new room
      @room = room
      @room_id = room.id
      @room.add_player(@player)
      
      # Save character
      save
    end

    def look
      return "You are not in a room." unless @room
      
      @room.to_s
    end

    def move(direction)
      return "You are not in a room." unless @room
      
      # Check if direction is valid
      unless @room.exits.key?(direction)
        return "You cannot go #{direction} from here."
      end
      
      # Get target room
      target_room_id = @room.exits[direction]
      target_room = Darkfang.world.get_room(target_room_id)
      
      unless target_room
        return "Error: Room '#{target_room_id}' not found."
      end
      
      # Move to target room
      enter_room(target_room)
      
      "You move #{direction} to #{target_room.name}.\n\n#{look}"
    end

    def say(message)
      return "You are not in a room." unless @room
      
      @room.broadcast("#{@name} says: #{message}")
      "You say: #{message}"
    end

    def shout(message)
      Darkfang.game.broadcast("#{@name} shouts: #{message}", except: @player)
      "You shout: #{message}"
    end

    def show_inventory
      if @inventory.empty?
        return "Your inventory is empty."
      end
      
      total_weight = @inventory.sum(&:weight)
      max_weight = 10 # Default max weight
      
      result = "Your inventory (#{total_weight}/#{max_weight} weight):\n"
      
      @inventory.each do |item|
        result += "- #{item.name} (#{item.weight})\n"
      end
      
      result
    end

    def take_item(item_name)
      return "You are not in a room." unless @room
      
      # Find item in room
      item = @room.find_item(item_name)
      
      unless item
        return "There is no #{item_name} here."
      end
      
      # Check if inventory has space
      total_weight = @inventory.sum(&:weight)
      max_weight = 10 # Default max weight
      
      if total_weight + item.weight > max_weight
        return "You cannot carry any more. Your inventory is full."
      end
      
      # Add item to inventory
      @inventory << item
      
      # Remove item from room
      @room.remove_item(item)
      
      # Save character
      save
      
      "You take the #{item.name}."
    end

    def drop_item(item_name)
      return "You are not in a room." unless @room
      
      # Find item in inventory
      item = @inventory.find { |i| i.name.downcase == item_name.downcase }
      
      unless item
        return "You don't have a #{item_name}."
      end
      
      # Remove item from inventory
      @inventory.delete(item)
      
      # Add item to room
      @room.add_item(item)
      
      # Save character
      save
      
      "You drop the #{item.name}."
    end

    def take_damage(amount)
      @health -= amount
      @health = 0 if @health < 0
      
      if @health <= 0
        die
      end
      
      save
    end

    def heal(amount)
      @health += amount
      @health = @max_health if @health > @max_health
      
      save
    end

    def die
      # Drop all items
      @inventory.each do |item|
        @room.add_item(item)
      end
      
      @inventory.clear
      
      # Reset health
      @health = @max_health
      
      # Move to start room
      start_room = Darkfang.world.start_room
      enter_room(start_room)
      
      @player.send_message("You have died and lost all your items. You have been returned to the starting room.")
    end

    def save
      Darkfang.game.save_character(self)
    end

    def to_json
      {
        "id" => @id,
        "name" => @name,
        "health" => @health,
        "max_health" => @max_health,
        "room_id" => @room_id,
        "inventory" => @inventory.map do |item|
          {
            "id" => item.id,
            "attributes" => item.instance_variables.each_with_object([]) do |var, result|
              key = var.to_s.delete("@")
              value = item.instance_variable_get(var)
              result << { key => value }
            end
          }
        end
      }.to_json
    end
  end
end
