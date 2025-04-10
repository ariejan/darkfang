# frozen_string_literal: true

module Darkfang
  # Represents a room in the game world
  class Room
    attr_reader :id, :name, :description, :exits, :items, :players, :automation

    def initialize(id, data)
      @id = id
      @name = data["name"]
      @description = data["description"]
      @exits = data["exits"] || {}
      @items = []
      @players = Set.new
      @automation = []

      if data["automation"] && data["automation"].is_a?(Array)
        data["automation"].each do |automation_data|
          @automation << Automation.create(automation_data, self)
        end
      end
    end

    def add_player(player)
      @players.add(player)
      broadcast("#{player.name} has entered the room.", except: player)
    end

    def remove_player(player)
      @players.delete(player)
      broadcast("#{player.name} has left the room.", except: player)
    end

    def add_item(item)
      @items << item
      broadcast("A #{item.name} appears in the room.")
    end

    def remove_item(item)
      @items.delete(item)
      broadcast("The #{item.name} disappears from the room.")
    end

    def find_item(item_name)
      @items.find { |item| item.name.downcase == item_name.downcase }
    end

    def broadcast(message, except: nil)
      @players.each do |player|
        next if player == except
        player.send_message(message)
      end
    end

    def to_s
      "#{@name}\n\n#{@description}\n\n" + 
      "Exits: #{@exits.keys.join(', ')}\n" +
      "Items: #{@items.map(&:name).join(', ')}\n" +
      "Players: #{@players.map(&:name).join(', ')}"
    end

    def run_automations
      @automation.each(&:run)
    end
  end
end
