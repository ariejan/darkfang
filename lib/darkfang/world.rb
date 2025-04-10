# frozen_string_literal: true

module Darkfang
  # Manages the game world, including rooms and items
  class World
    attr_reader :rooms, :items

    def initialize
      @rooms = {}
      @items = {}
      @loaded = false
    end

    def load
      return if @loaded

      load_rooms
      load_items
      
      @loaded = true
    end

    def load_rooms
      rooms_dir = File.join(Darkfang.root, "rooms")
      return unless Dir.exist?(rooms_dir)

      Dir.glob(File.join(rooms_dir, "*.yml")).each do |room_file|
        begin
          data = YAML.safe_load_file(room_file, permitted_classes: [Symbol])
          next unless data["room"]

          room_id = File.basename(room_file, ".yml")
          @rooms[room_id] = Room.new(room_id, data["room"])
          
          Darkfang.logger.info("Loaded room: #{room_id}")
        rescue => e
          Darkfang.logger.error("Error loading room #{room_file}: #{e.message}")
        end
      end
    end

    def load_items
      items_dir = File.join(Darkfang.root, "items")
      return unless Dir.exist?(items_dir)

      Dir.glob(File.join(items_dir, "*.yml")).each do |item_file|
        begin
          data = YAML.safe_load_file(item_file, permitted_classes: [Symbol])
          next unless data["item"]

          item_id = File.basename(item_file, ".yml")
          @items[item_id] = Item.new(item_id, data["item"])
          
          Darkfang.logger.info("Loaded item: #{item_id}")
        rescue => e
          Darkfang.logger.error("Error loading item #{item_file}: #{e.message}")
        end
      end
    end

    def get_room(room_id)
      @rooms[room_id]
    end

    def get_item(item_id)
      @items[item_id]
    end

    def start_room
      @rooms["start"] || @rooms.values.first
    end

    def create_item_instance(item_id)
      item_template = get_item(item_id)
      return nil unless item_template

      # Create a deep copy of the item
      Item.new(item_id, item_template.instance_variables.each_with_object([]) do |var, result|
        key = var.to_s.delete("@")
        value = item_template.instance_variable_get(var)
        result << { key => value }
      end)
    end

    def run_automations
      @rooms.each_value(&:run_automations)
    end
  end
end
