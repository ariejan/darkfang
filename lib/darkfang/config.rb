# frozen_string_literal: true

module Darkfang
  # Configuration loader and validator for Darkfang
  class Config
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def self.load
      config_file = File.join(Darkfang.root, "darkfang.yml")
      
      unless File.exist?(config_file)
        raise ConfigurationError, "Configuration file not found: #{config_file}"
      end

      begin
        data = YAML.safe_load_file(config_file, permitted_classes: [Symbol])
        new(data)
      rescue => e
        raise ConfigurationError, "Error loading configuration: #{e.message}"
      end
    end

    def validate!
      errors = []

      # Check for required sections
      errors << "Missing 'server' section in configuration" unless data["server"]
      errors << "Missing 'darkfang' section in configuration" unless data["darkfang"]
      
      # Check server configuration
      if data["server"]
        errors << "Missing 'server.host' in configuration" unless data["server"]["host"]
        errors << "Missing 'server.port' in configuration" unless data["server"]["port"]
      end
      
      # Check darkfang configuration
      if data["darkfang"]
        errors << "Missing 'darkfang.title' in configuration" unless data["darkfang"]["title"]
        errors << "Missing 'darkfang.description' in configuration" unless data["darkfang"]["description"]
      end

      # Check for required directories
      rooms_dir = File.join(Darkfang.root, "rooms")
      items_dir = File.join(Darkfang.root, "items")
      
      errors << "Missing 'rooms' directory" unless Dir.exist?(rooms_dir)
      errors << "Missing 'items' directory" unless Dir.exist?(items_dir)
      
      # Check for start room
      start_room = File.join(rooms_dir, "start.yml")
      errors << "Missing start room: #{start_room}" unless File.exist?(start_room)

      raise ValidationError, errors.join("\n") unless errors.empty?
      
      true
    end

    def server_host
      data.dig("server", "host") || "0.0.0.0"
    end

    def server_port
      data.dig("server", "port") || 4532
    end

    def title
      data.dig("darkfang", "title") || "Untitled Darkfang"
    end

    def description
      data.dig("darkfang", "description") || "No description provided."
    end
  end
end
