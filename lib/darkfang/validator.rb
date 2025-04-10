# frozen_string_literal: true

module Darkfang
  # Validator for Darkfang game data
  class Validator
    attr_reader :errors

    def initialize
      @errors = []
    end

    def validate!
      validate_config
      validate_rooms
      validate_items

      if @errors.empty?
        true
      else
        raise ValidationError, @errors.join("\n")
      end
    end

    def validate_config
      Darkfang.load_config
      Darkfang.config.validate!
    rescue ConfigurationError, ValidationError => e
      @errors << e.message
    end

    def validate_rooms
      rooms_dir = File.join(Darkfang.root, "rooms")
      return unless Dir.exist?(rooms_dir)

      Dir.glob(File.join(rooms_dir, "*.yml")).each do |room_file|
        begin
          data = YAML.safe_load_file(room_file, permitted_classes: [Symbol])
          
          unless data["room"]
            @errors << "Missing 'room' section in #{room_file}"
            next
          end

          room_data = data["room"]
          
          @errors << "Missing 'name' in #{room_file}" unless room_data["name"]
          @errors << "Missing 'description' in #{room_file}" unless room_data["description"]
          
          # Validate automation if present
          if room_data["automation"]
            unless room_data["automation"].is_a?(Array)
              @errors << "Automation must be an array in #{room_file}"
              next
            end

            room_data["automation"].each do |automation|
              unless automation["type"]
                @errors << "Missing 'type' in automation in #{room_file}"
              end

              if automation["type"] == "cron" && !automation["cron"]
                @errors << "Missing 'cron' in cron automation in #{room_file}"
              end
            end
          end
        rescue => e
          @errors << "Error validating #{room_file}: #{e.message}"
        end
      end
    end

    def validate_items
      items_dir = File.join(Darkfang.root, "items")
      return unless Dir.exist?(items_dir)

      Dir.glob(File.join(items_dir, "*.yml")).each do |item_file|
        begin
          data = YAML.safe_load_file(item_file, permitted_classes: [Symbol])
          
          unless data["item"]
            @errors << "Missing 'item' section in #{item_file}"
            next
          end

          item_data = data["item"]
          
          unless item_data.is_a?(Array)
            @errors << "Item data must be an array in #{item_file}"
            next
          end

          # Check for required attributes
          has_name = false
          has_weight = false
          has_description = false
          
          item_data.each do |attr|
            has_name = true if attr.key?("name")
            has_weight = true if attr.key?("weight")
            has_description = true if attr.key?("description")
          end
          
          @errors << "Missing 'name' in #{item_file}" unless has_name
          @errors << "Missing 'weight' in #{item_file}" unless has_weight
          @errors << "Missing 'description' in #{item_file}" unless has_description
        rescue => e
          @errors << "Error validating #{item_file}: #{e.message}"
        end
      end
    end
  end
end
